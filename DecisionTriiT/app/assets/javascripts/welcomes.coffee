$(document).on 'ajax:success', 'form#array-form', (ev, data) ->
  console.log data
  $("#list-box").append("<li>#{data.id} - #{data.content}</li>")
  $("#new_id").html  "Id: #{data.size}"
  $('#my_form').load location.href + ' #my_form'

$('#list-box a.clear').click ->
  $(this).parent().remove()
  false