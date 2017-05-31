/**
 * Consists of scripts for all pages.
 *
 * Created by hfeild on 30-May-2017.
 */


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


$(document).ready(function(){
  embed_html();

});