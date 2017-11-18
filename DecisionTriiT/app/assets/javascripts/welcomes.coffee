$(document).on 'ajax:success', 'form#array-form', (ev, data) ->
  console.log data
  $("#list-box").append("<li>#{data.content}</li>")
  $("#new_id").html "Id: #{data.size}"
  $("#to_select").html "f.select(:parent, #{data.ids}.map{ |value| [ value, value ] })"