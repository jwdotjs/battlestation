// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"


function getValueFromTd(elem) {
  return $(elem).children('input').val() || $(elem).html().trim();
}

$(document).ready(function() {
  $('body').on('click', 'table tr.jq__existing-vm td', function() {
    if ($(this).children('input').length > 0) {
      return false; // its already an input, don't convert it again
    }

    var type = $(this).data('type');
    var val = type !== 'running_locally' ?
      $(this).html().trim() : ($(this).html() === '-' ? 'false' : 'true');

    $(this).html('<input type="text" name="' + type + '" value="' + val + '" />');
    $(this).children('input').focus();
  });

  $('body').on('keyup', 'table tr.jq__existing-vm td', function(e) {
    if (e.keyCode == 13) {
      var val = $(this).children('input').val();
      $(this).html(val);

      var vm_name = getValueFromTd($(this).parent('tr').children('td[data-type="vm_name"]'));
      var running_locally = getValueFromTd($(this).parent('tr').children('td[data-type="running_locally"]'));
      if (running_locally === "-" || running_locally === "false") {
        running_locally = false;
      } else {
        running_locally = true;
      }

      var ip_address = getValueFromTd($(this).parent('tr').children('td[data-type="ip_address"]'));
      var csrf = document.querySelector("meta[name=csrf]").content;

      var payload = {vm : {vm_name: vm_name, ip_address: ip_address, running_locally: running_locally}};

      $.ajax({
        url: '/',
        type: 'PUT',
        headers: {
          "X-CSRF-TOKEN": csrf,
        },
        dataType: "json",
        data: payload,
        success: function(result) {
          window.location.reload();
        }
      });
    } else if (e.keyCode == 27) {
      var val = $(this).children('input').val();
      $(this).html(val);
    }
  });

  $('.jq__new-vm').on('click', function() {
    $('.jq__new-vm').before(
      '<tr class="jq__existing-vm">' +
        '<td data-type="vm_name">Name of VM</td>' +
        '<td data-type="ip_address">Unknown ip</td>' +
        '<td data-type="running_locally">-</td>' +
      '</tr>'
    );
  });
});
