/**
 * Consists of scripts for all pages.
 *
 * Created by hfeild on 30-May-2017.
 */

/**
 * Initializes listeners when the document loads.
 */
$(document).ready(function(){
  embed_html();
  
  $(document).on('change', '.submit-toggle-field', toggleSubmitOnFieldChange);
  $(document).on('keyup', '.submit-toggle-field', toggleSubmitOnFieldChange);

  highlightVerticalHeaderLink();
});

/**
 * Finds all iframe tags with the class 'embed-html', then creates a document
 * in the iframe and sticks whatever is in the 'data-html' attribute for the
 * iframe tag. The value of 'data-html' is assumed to be URL encoded.
 */
var embed_html = function(){
  var computed_style = window.getComputedStyle(document.body);
  
  $('iframe.embed-html').each(function(i, elm){
    this.contentWindow.document.open();
    this.contentWindow.document.write(decodeURIComponent($(this).data('html')));
    this.contentWindow.document.close();

    // Set fonts.
    this.contentWindow.document.body.style.fontFamily = 
      computed_style.fontFamily;
    this.contentWindow.document.body.style.fontSize =
      computed_style.fontSize;

    // Set the height of the frame to match the document.
    $(this).height(this.contentWindow.document.body.scrollHeight);

  });
}

/**
 * Returns the max scrollY of the page. This was snagged from stackoverflow:
 * https://stackoverflow.com/a/17698713
 *
 * @return The max scroll y of the page.
 */
var scrollYMax = function(){
  return Math.max( 
    document.body.scrollHeight, 
    document.body.offsetHeight, 
    document.documentElement.clientHeight, 
    document.documentElement.scrollHeight, 
    document.documentElement.offsetHeight ) - window.innerHeight;
}

/**
 * Makes an ajax call based on a button with the following attributes:
 *
 *  - href (the url to submit to)
 *  - method (get, post, put, or delete)
 *  - data (the data to send)
 *
 * Non-get or post methods are sent as post and a _method key is added to
 * the data
 *
 * @param buttonElm The button element.
 * @param onSuccess The function for jQuery.ajax to call on success.
 * @param onError The function for jQuery.ajax to call on error.
 */
var ajaxFromComplexButtonLink = function(buttonElm, onSuccess, onError){
  var jElm = $(buttonElm);
  var data = jElm.data('data');
  
  // Handle non get/post methods.
  var method = jElm.data('method').toLowerCase();
  if(method !== 'get' && method !== 'post'){
    data += "&_method="+method;
    method = 'post';
  }
  
  $.ajax(jElm.data('href'), {
    data: data,
    method: method,
    success: onSuccess,
    error: onError
  });
};

/**
 * Disables a button if the field bound to this function is empty. Otherwise
 * enables it.
 *
 * @param e The JavaScript event that triggered.
 */
var toggleSubmitOnFieldChange = function(e){
  var fieldElm = $(this);
  var submitElm = fieldElm.parents('form').find('[type=submit]');
  
  // Disable the submit button if the field isn't set.
  if(this.value === ''){
    submitElm.prop('disabled', true);
    
  // Enable the submit button if the field is set.
  } else {
    submitElm.prop('disabled', false);
    
  }
}

/**
 * Detects if a vertical page is loaded and applies a class to that vertical's
 * header link.
 */
var highlightVerticalHeaderLink = function(){
  var vertical = window.location.pathname.match(/^\/(\w*)/)[1];
  var elm = $('#header-'+ vertical +'-link');
  if(elm.size() > 0){
    elm.addClass('selected-vertical');
  }
}
