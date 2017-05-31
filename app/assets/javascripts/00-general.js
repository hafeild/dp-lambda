
var embed_html = function(){
  $('iframe.embed-html').each(function(i, elm){
    this.contentWindow.document.open();
    this.contentWindow.document.write(decodeURIComponent($(this).data('html')));
    this.contentWindow.document.close();
    this.style.height = this.contentWindow.document.height;
  });

}


$(document).ready(function(){
  embed_html();

});