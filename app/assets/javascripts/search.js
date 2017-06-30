/**
 * Consists of scripts for search engine results pages (SERPs).
 *
 * Created by hfeild on 29-June-2017.
 */

$(document).ready(function(event){
  
  // Listens for a vertical search tab to be clicked and then issues the
  // query to that vertical.
  $('.serp .vertical-tab').on('click', function(event){
    var form = $('#search-box-form');
    form.attr('action', '/search/'+ $(this).data('vertical'));
    form.submit();
  });
  
  // Listens for the infinite scroll marker to come into view; if so, fetches
  // more results if there are any.
  $(document).on('scroll', function(){
    console.log(window.scrollY, scrollYMax());
    // Check if we're at the bottom of the page.
    if(window.scrollY == scrollYMax() && 
        $('.no-more-results').hasClass('hidden') && 
        $('.loading-more-results').hasClass('hidden')){
      
      $('.loading-more-results').removeClass('hidden');
    
    
    }
  });
});