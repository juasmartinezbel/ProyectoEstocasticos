$(document).on 'ajax:success', 'form#array-form', (ev, data) ->
  console.log data
  $("#list-box").append("<li>#{data.content}</li>")