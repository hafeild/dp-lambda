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
});

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


var addUser = function(event, ui){
  var userId = ui.item.value;
  var userName = ui.item.label;

  // Create a new element in the picked-users list.
  var user = $(`<span class="user" data-id="${userId}"><span class="name">${userName}</span></span>`);
  user.append('<span class="remove-user"><span class="glyphicon glyphicon-remove"></span></span>');
  $('#picked-users').append(user);

  // Clear the search box.
  $('#user-search').val('');

  translateUsersToIds();

  event.preventDefault();
  return false;
};

var removeUser = function(){
  $(this).parents('.user').remove();
  translateUsersToIds();
};

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