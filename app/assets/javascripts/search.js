/**
 * Consists of scripts for search engine results pages (SERPs).
 *
 * Created by hfeild on 29-June-2017.
 */

$(document).ready(function(event){
  
  // Listens for a vertical search tab to be clicked and then issues the
  // query to that vertical.
  $('.serp .vertical-tab').on('click', function(event){
    var vertical = $(this).data('vertical');
    var url = window.location.href;
    var params = url.substr(url.indexOf('?'));
    window.location = '/search/'+ vertical + params;
  });
  
  // Handles infinite scrolling.
  if($('.infinite-scroll').length > 0){
    // If all results are displayed on the screen, don't load more results.
    // Instead, reveal a button that the user must press to get them started.
    if(!$('.no-more-results').hasClass('hidden') || 
        scrollYMax() - window.scrollY > 50){
      $('.click-for-more-results').addClass('hidden');
    }
    
    // Listens for the infinite scroll marker to come into view; if so, fetches
    // more results if there are any.
    var checkInfiniteScroll = function(){
      // Check if we're at the bottom of the page.
      if(window.scrollY == scrollYMax() && 
          $('.no-more-results').hasClass('hidden') && 
          $('.loading-more-results').hasClass('hidden') &&
          $('.error').hasClass('hidden') &&
          $('.click-for-more-results').hasClass('hidden')){
        
        getAdditionalResults();
      }
    };
    
    $(document).on('scroll', checkInfiniteScroll);
    $(window).on('resize',  checkInfiniteScroll);
    
    
    $(document).on('click', '.click-for-more-results', function(){
      $(this).addClass('hidden');
      getAdditionalResults();
    });
    
    var getAdditionalResults = function(){
      // Show the loading message.
      $('.loading-more-results').removeClass('hidden');
      
      var infiniteScroll = $('.infinite-scroll');
      var vertical = infiniteScroll.data('vertical');
      
      // Get the new results.
      $.ajax(vertical, {
        data: {
          q: encodeURIComponent(infiniteScroll.data('query')),
          format: 'json',
          cursor: infiniteScroll.data('next-page-cursor'),
          sr: infiniteScroll.data('next-rank')
        },
        dataType: 'json',
        success: function(data){
          if(!data.success){
            infiniteScroll.find('.message').addClass('hidden');
            infiniteScroll.find('.error').removeClass('hidden');
            return;
          }
          
          $('.results').append(data.result_set_html);
          infiniteScroll.find('.message').addClass('hidden');
          infiniteScroll.data('next-page-cursor', data.next_page_cursor);
          infiniteScroll.data('next-rank', data.next_rank);
          if(data.last_page){
            infiniteScroll.find('.no-more-results').removeClass('hidden');
          }
        },
        error: function(qXHR, textStatus, error){
          infiniteScroll.find('.message').addClass('hidden');
          infiniteScroll.find('.error').removeClass('hidden');
        }
      });
    };
  }
  
  $(document).on('click', '.trigger-advanced-search', function(event){
    $('.advanced-search-control').toggleClass('hidden');
    event.preventDefault();
  });
  
  $(document).on('click', '.hide-advanced-search', function(event){
    $('.advanced-search-control').toggleClass('hidden');
    event.preventDefault();
  });
  
  $('.advanced-search-form').on('submit', function(){
    $(this).attr('action', '/search/'+ $(this.vertical).val());
  });
});