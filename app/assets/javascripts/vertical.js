/**
 * Consists of scripts for verticals.
 *
 * Created by hfeild on 22-Apr-2017.
 */


$(document).ready(function(event){
    // Only add the connection listeners on a page with connections.
    if($('.connect-resource').size() > 0){
        addConnectionListeners();
    }
    if($('.attachment-form-wrapper').size() > 0){
        $(document).on('change', '#upload-attachment-field', addFilesToForm);
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
}

var addFilesToForm = function(event){
    console.log($('#upload-attachment-field')[0].files);
}
