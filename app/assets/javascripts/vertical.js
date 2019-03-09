/**
 * Consists of scripts for verticals.
 *
 * Created by hfeild on 22-Apr-2017.
 */

// Keycodes
var LEFT = 37;
var RIGHT = 38;
var UP = 39;
var DOWN = 40;
var listIndex = -1;
var maxSuggestionIndex = 0;
var processingCounter = 0;
var processing = false;
var processingId;

var currentUserSuggestionLookup = {};

/**
 * Initializes listeners and calls setup functions when the page loads.
 */
$(document).ready(
function(event){
  // Only add the connection listeners on a page with connections.
  if($('.connect-resource').size() > 0){
    addConnectionListeners();
  }
  if($('.attachment-form-wrapper').size() > 0){
    //$(document).on('change', '#upload-attachment-field', addFilesToForm);
    $(document).on('click', '.toggle-edit-file-attachment', toggleFileAttachmentEdit);
    $('.file-attachments-list').sortable({
      handle: '.grip',
      stop: reorderAttachments,
      start: function(event, ui){ ui.helper.addClass('dragging'); }
    });
  }
  if($('.edit-toggle').size() > 0){
    initializeEditMode();
    $(document).on('click', '.enable-editing', toggleEditMode);
    $(document).on('click', '.disable-editing', toggleEditMode);
  }
  
  $(document).on('click', '.no-submit', cancelFormSubmissionFollowLink);

  // User search suggestions for adding authors/instructors on assignment 
  // [group] pages.
  if($('#user-search').size() > 0){
    // $(document).on('keydown', '#user-search', getUserSuggestions);
    $("#user-search").autocomplete({
      source: getUserSuggestions,
      select: addUser,
      focus: (e,ui) => e.preventDefault()
    });
    $('#user-search').keypress(e =>{
        if (e.keyCode == 13) {
          e.preventDefault();
          e.stopPropagation();
        }
      }
    );
    $(document).on('mousedown', '.add-user', addUser);
    $(document).on('mousedown', '.remove-user', removeUser);
    // Copy over all of the picked user to the user-search-target field.

  }

  // User stub form submission.
  $(document).on('submit', '.user-stub-form form', submitUserStubForm);
  $(document).on('userstub:created', addStubUser);
  $(document).on('show.bs.modal', '.new-user-stub-modal', (event) => {
    $('.user-stub-form-toggle').addClass('hidden');
    $('.user-stub-form').removeClass('hidden');
  });

});

/**
 * Animates a processing indicator:
 * 
 *    Processing
 *    Processing.
 *    Processing..
 *    Processing...
 *    Processing
 *    ...
 * 
 * On the first call, set the second parameter to true. The animation will
 * continue until the global `processing` flag is turned off.
 * 
 * @param $elm The jQuery element to add the text to.
 * @param start Whether to start the animation (true) or continue an existing 
 *              anitmation (false). If the former, the global `processing` flag 
 *              will be set to true; otherwise, the global `processing` flag 
 *              will be checked an the animation will only continue if 
 *              `processing` is true. Default: false.
 */
var animateProcessing = function($elm, start){
  if(start){
    processing = true;
    processingId = setInterval(animateProcessing, 250, $elm);
    processingCounter = 0;
  }

  if(processing){
    processingCounter = processingCounter % 4;
    if(processingCounter == 0){
      $elm.text('Processing');
    } else if(processingCounter == 1){
      $elm.text('Processing.');
    } else if(processingCounter == 2){
      $elm.text('Processing..');
    } else {
      $elm.text('Processing...');
    }
    processingCounter++;

  } else {
    clearInterval(processingId);
  }
};

/**
 * Turns off processing animation.
 */
var unanimateProcessing = function(){
  processing = false;
}

/**
 * Submits a new user stub form. Updates the modal to display an animation
 * until the server is heard back from. Then either displays an error message
 * or the newly created user is added to the list of authors/instructors for
 * the assignment.
 * 
 * @param event The submission event that trigger this.
 */
var submitUserStubForm = function(event){
  var $form = $(this);

  $('.user-stub-form-toggle').addClass('hidden');
  var $processingDiv = $('.user-stub-wait') 

  // Show the processing modal.
  $processingDiv.removeClass('hidden');

  $.post({
    url: '/user_stubs',
    data: $form.serialize(),
    success: function(data){
      console.log(data);

      unanimateProcessing();

      // Handle any errors.
      if(!data.success){
        userStubSubmissionError(data.error);
        return;
      }

      var user = data.data.user_stub.json;
      $(document).trigger('userstub:created', [user.id,
        `${user.first_name} ${user.last_name} (${user.username})`]);

      // Close the modal.
      $('.new-user-stub-modal').modal('hide');
    },
    error: function(jqXHR, textStatus, errorThrown){
      unanimateProcessing();
      userStubSubmissionError(errorThrown);
    },
    dataType: 'json'
  });
  
  animateProcessing($processingDiv.find('.message'), true);

  event.preventDefault();
}

/**
 * Raises an error in the user stub modal.
 * @param error The error to display.
 */
var userStubSubmissionError = function (error){
  $('.user-stub-form-toggle').addClass('hidden');
  var $errorDiv = $('.user-stub-error');
  $errorDiv.removeClass('hidden')
  $errorDiv.find('.error-message').html(error);
}

/**
 * Adds the given id to the picked-users list.
 *  
 * @param event The event that triggered this (can be null).
 * @param userId The id of the user.
 * @param displayName The display name of the user e.g., (first and last name
 *                    (username)).
 */
var addStubUser = function(event, userId, displayName){
  // Create a new element in the picked-users list.
  var user = $(`<span class="user" data-id="${userId}"><span class="name">`+
               `${displayName}</span></span>`);
  user.append(
    '<span class="remove-user"><span class="glyphicon glyphicon-remove">'+
    '</span></span>');
  $('#picked-users').append(user);
  translateUsersToIds();
}

/**
 * Hits the server to gather user suggestions based on what has been entered
 * into the search box. Each suggestions includes a label (first and last name)
 * and value (user id) field.
 * 
 * @param autoSuggestInput The text that's been entered.
 * @param autoSuggestCallback  The function to call after generating the 
 *                             list of suggestions.
 */
var getUserSuggestions = function(autoSuggestInput, autoSuggestCallback){
  var query = autoSuggestInput.term; //this.value;

  $.ajax(`/search/users/${encodeURIComponent(query)}`,{
    data: {format: 'json'},
    method: 'get',
    success: function(response){
      var suggestions = [];
      currentUserSuggestionLookup = {};

      if(response.res){
        response.res.forEach(u => 
          suggestions.push({
            label: `${u.name} (${u.username})`,
            value: u.id
          })
        );
      } 
      autoSuggestCallback(suggestions);
    },
    error: function(jqXHR, textStatus, error){
      alert('Error: '+ textStatus +' '+ error);
      autoSuggestCallback([]);
    }
  });

};

/**
 * Processes a user selected from the user suggestion; add them to the picked
 * users list.
 * 
 * @param event The event that triggered this.
 * @param ui The jQuery UI element that was selected. Should have
 *          item.value and item.label fields.
 */
var addUser = function(event, ui){
  var userId = ui.item.value;
  var userName = ui.item.label;

  addStubUser(null, userId, userName);

  // Clear the search box.
  $('#user-search').val('');

  event.preventDefault();
  return false;
};

/**
 * Removes a user from the picked users list.
 */
var removeUser = function(){
  $(this).parents('.user').remove();
  translateUsersToIds();
};

/**
 * Adds the id of every picked user to the hidden form field for picked users
 * (this id list is what the server processes to add those users as authors
 * or instructors).
 */
var translateUsersToIds = function(){
  var ids = $.map($('#picked-users .user'), (elm,i) => elm.getAttribute('data-id'));
  console.log('ids:', ids);
  $('.user-search-target').val(ids.join(','));
};


/**
 * Adds listeners to vertical connections (e.g., connect a software entry to
 * an assignment).
 */
var addConnectionListeners = function(){
  // Wait for a click.
  $(document).on('click', '.connect-resource button', function(){
    // Add or remove the connection based on the button that was clicked,
    // then update the button once hearing back from the server.
    var connection = $(this).parent();
    var action = $(this).data('action');
    var method = action == 'remove' ? 'delete' : 'post';
    $.ajax(connection.data('url'), {
      data: {_method: method, format: 'json'},
      method: 'post',
      success: function(response){
        if(response.success){
          connection.find('button').toggleClass('hidden');
          connection.parent().toggleClass('added');
        }
      },
      error: function(jqXHR, textStatus, error){
        alert('Error: '+ textStatus +' '+ error);
      }
    });
  })
};

/**
 * Prevents a form from being submitted when a button click occurs, but 
 * follows the link.
 *
 * @param event The click event that triggered this.
 */
var cancelFormSubmissionFollowLink = function(event){
  event.preventDefault();
  window.location = $(this).data('href');
};

/**
 * Hides or shows the file attachment information or edit form.
 * 
 * @param event The event that triggered this function.
 */
var toggleFileAttachmentEdit = function(event){
  event.preventDefault();  
  $(this).parents('li').find('.file-attachment-wrapper').toggleClass('hidden');
};

/**
 * Checks if the attachments list has been reordered, and if it has, tells the
 * server to update the database.
 * 
 * @param event An event object.
 * @param ui A jQuery UI object specifying what element moved and where.
 */
var reorderAttachments = function(event, ui){
  var changes = 0;
  var attachmentsInOrder = [];

  // Hide the decoration of the moving assignment.
  ui.item.removeClass('dragging');

  // See what has changed (or did the user drop the attachment where it
  // started?).
  $('.file-attachment').each(function(i, elm){
    elm = $(elm);
    if(i != elm.data('display-position')){
      changes++;
    }
    attachmentsInOrder.push(elm.data('attachment-id'));
    elm.data('display-position', i);
  });

  // If something has changed, send the new ordering to the server so the DB
  // can be updated.
  if(changes > 0){
    console.log('Making a call to:', $('.file-attachments').data('reorder-url'));
    $.ajax($('.file-attachments').data('reorder-url'), {
      method: 'post',
      data: {
        _method: 'put', 
        format: 'json', 
        attachments: attachmentsInOrder
      },
      error: function(jqXHR, textStatus, error){ 
        alert("There was an error saving your reordering. Please try again later.")
        console.log('Error: '+ textStatus +' '+ error);
      },
      success: function(data){
        if(data.error){
          alert("There was an error saving your reordering. Please try again later.");
          return;
        }
      }
    });
  }
};

/**
 * Hides/shows edit buttons based on which mode the user was most recently in.
 * Defaults to off. Relies on localStorage to save data persistently, so only
 * affects current browser.
 */
var initializeEditMode = function(){
  var inEditMode = (window.localStorage.editMode === 'true');
  if(inEditMode){
    $('.edit-toggle').show();
    $('.enable-editing').hide();
  } else {
    $('.enable-editing').show();
  }
  window.localStorage.editMode = inEditMode;
};

/**
 * Toggles edit mode on an off. Saves the current mode in localStorage.
 * 
 * @param event Ignored.
 */
var toggleEditMode = function(event){
  window.localStorage.editMode = (window.localStorage.editMode!=='true');
  $('.edit-toggle').toggle();
}