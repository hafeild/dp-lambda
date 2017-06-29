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
});