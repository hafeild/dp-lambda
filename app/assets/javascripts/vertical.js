/**
 * Consists of scripts for verticals.
 *
 * Created by hfeild on 22-Apr-2017.
 */


/**
 * Initializes listeners and calls setup functions when the page loads.
 */
$(document).ready(function(event){
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
});

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