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
});

// Adds listeners to vertical connections (e.g., connect a software entry to
// an assignment).
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



