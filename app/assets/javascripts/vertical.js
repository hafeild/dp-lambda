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

  if(form.data('id')){
    form.data('removed', true);
    form.hide();
  } else {
    form.remove();
  }

  event.stopPropagation();
  event.preventDefault();
});

// Whenever an input/text area is modified, this removes the 'unchanged' class.
$(document).on('input', '.vertical-modification input, '+
    '.vertical-modification textarea', function(event){
  $(this).removeClass('unchanged');
});

// Converts vertical form fields to form encoding, adds them as hidden fields,
// and disables all .ignore fields. This is called before the form is submitted.
$(document).on('submit', '.vertical-modification form', function(event){
  var formJq = $(this);
  var resources = ['tags', 'web_resources', 'examples'];
  var vertical = $('.vertical-modification').data('vertical');
  var serializedParams = '';
  var params = {};
  params[vertical] = {}

  event.stopPropagation();
  event.preventDefault();

  // Gather the params from each resource section into a JavaScript object.
  $.each(resources, function(i, resource){
    console.log('Searching '+ resource);
    var resourceParams = [];

    formJq.find('.'+ resource +' .resource-form').each(function(j, elm){
      console.log('- considering resource form', elm);

      elm = $(elm);
      var entry = {};

      elm.find('input.ignore, textarea.ignore').each(function(k, input){
        console.log('-- considering input.ignore', input);

        input = $(input);
        if(!input.hasClass('unchanged')){
          entry[input.attr('name')] = input.val();
        }
      });

      resourceParams.push(entry);
    });

    if(resourceParams.length > 0)
      params[vertical][resource] = resourceParams;
  });

  // Gather all of the other parameters from the form.
  formJq.find('input,textarea').each(function(i, input){
    input = $(input);
    if(input.hasClass('ignore')) return;

    if(input.hasClass('add-to-vertical')){
      params[vertical][input.attr('name')] = input.val();
    } else {
      params[input.attr('name')] = input.val();
    }
  });

  // Send the data to the server.
  $.ajax(formJq.attr('action'), {
    method: 'post',
    data: JSON.stringify(params),
    dataType: 'json',
    contentType: 'application/json',
    success: function(response){
      console.log('heard back from the server:', response);

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
      console.log('jqXHR', jqXHR);
      alert('Error: '+ textStatus +' '+ error);
    }
  });

  return false;
});
// End edit/update pages.
/////////////////////////