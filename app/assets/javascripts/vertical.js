/**
 * Consists of scripts for verticals.
 *
 * Created by hfeild on 22-Apr-2017.
 */

/////////////////////
// Edit/update pages.

// Adds a new resource form from the *-form-template.
$(document).on('click', '.resource .add', function(event){
  var resource = $(this).data('resource');
  $('#'+ resource +'-form-template').clone().attr('id', '').appendTo($(this).
    parents('.resource'));
  event.stopPropagation();
  event.preventDefault();
});

// Removes a resource form; if an id is present, then it is marked as deleted
// and hidden, but still included in the resource form so the changes can be
// submitted to the server.
$(document).on('click', '.resource-form .remove', function(event){
  var form = $(this).parents('.resource-form');

  if(form.hasClass('saved')){
    form.data('removed', true);
    form.hide();
    $('<input class="ignore" name="remove" value="true" type="hidden"/>').appendTo(form);
    form.removeClass('unchanged');
  } else {
    form.remove();
  }

  event.stopPropagation();
  event.preventDefault();
});

// Whenever an input/text area is modified, this removes the 'unchanged' class.
$(document).on('change', '.vertical-modification input, '+
    '.vertical-modification textarea', function(event){
  $(this).removeClass('unchanged');
  $(this).parents('.resource-form').removeClass('unchanged');
  $('#form-submit').prop('disabled', false);
});


// Listens for clicks on any elements with a link class. E.g., the cancel 
// button.
$(document).on('click', '.link', function(event){
  window.location = $(this).data('href');
  event.stopPropagation();
  event.preventDefault();
});

// Converts vertical form fields to form encoding, adds them as hidden fields,
// and disables all .ignore fields. This is called before the form is submitted.
$(document).on('submit', '.vertical-modification form', function(event){
  event.stopPropagation();
  event.preventDefault();

  var formJq = $(this);
  var resources = ['tags', 'web_resources', 'examples'];
  var vertical = $('.vertical-modification').data('vertical');
  var serializedParams = '';
  var params = {};
  params[vertical] = {}

  // Gather the params from each resource section into a JavaScript object.
  $.each(resources, function(i, resource){
    var resourceParams = [];

    formJq.find('.'+ resource +' .resource-form').each(function(j, elm){
      elm = $(elm);
      var entry = {};

      // Ignore any unchanged forms.
      if(elm.hasClass('unchanged')) return;

      elm.find('input.ignore, textarea.ignore').each(function(k, input){
        input = $(input);
        // Only add values that have been modified.
        if(!input.hasClass('unchanged')){
          entry[input.attr('name')] = input.val();
        }
      });

      resourceParams.push(entry);
    });

    if(resourceParams.length > 0){
      params[vertical][resource] = resourceParams;
    }
  });

  // Gather all of the other parameters from the form.
  formJq.find('input,textarea').each(function(i, input){
    input = $(input);
    if(input.hasClass('ignore') || input.hasClass('unchanged')) return;

    if(input.hasClass('add-to-vertical')){
      params[vertical][input.attr('name')] = input.val();
    } else {
      params[input.attr('name')] = input.val();
    }
  });

  // Send the data to the server.
  $.ajax(formJq.attr('action')+'.json', {
    method: params._method ? params._method : formJq.attr('method'),
    data: JSON.stringify(params),
    dataType: 'json',
    contentType: 'application/json',
    success: function(response){
      if(!response){
        return;
      } else if(response.success){
        window.location = response.redirect;
      } else {
        alert('Error: '+ response.error);
        formJq.find('input[type=submit]').prop('disabled', false);
      }
    },
    error: function(jqXHR, textStatus, error){
      alert('Error: '+ textStatus +' '+ error);
    }
  });

  return false;
});
// End edit/update pages.
/////////////////////////