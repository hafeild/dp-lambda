/**
 * Consists of scripts for admin pages.
 *
 * Created by hfeild on 03-Dec-2017.
 */
 
/**
 * Handles clicks on "grant" and "decline" buttons for permission requests.
 */
var processPermissionRequestAction = function(event){
  var jelm = $(this);
  
  var onError = function(jqXHR, textStatus, errorThrown){
    alert('There was an error while processing your request: '+ errorThrown);
  }

  var onSuccess = function(data){
    if(!data.success){
      onError(null, null, data.error);
      return;
    }
    
    var request = data.permission_request;
    jelm.parents('td').html(
      'Reviewed and '+ (request.granted ? 'granted' : 'declined') +
      ' by '+ request.reviewed_by_username + ' on '+ request.reviewed_on +'.'
    );
    
  }
  
  // From 00-general.js.
  ajaxFromComplexButtonLink(this, onSuccess, onError);
}

$(document).ready(function(){
  $(document).on('click', '.permission-requests-table .complex-button-link', 
    processPermissionRequestAction);
  
});