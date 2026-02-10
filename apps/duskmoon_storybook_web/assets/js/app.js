import "phoenix_html";

// Register custom elements individually
import "@duskmoon-dev/el-button/register";
import "@duskmoon-dev/el-card/register";
import "@duskmoon-dev/el-input/register";
import "@duskmoon-dev/el-switch/register";
import "@duskmoon-dev/el-alert/register";
import "@duskmoon-dev/el-dialog/register";
import "@duskmoon-dev/el-badge/register";
import "@duskmoon-dev/el-tooltip/register";
import "@duskmoon-dev/el-progress/register";
import "@duskmoon-dev/el-form/register";
import "@duskmoon-dev/el-slider/register";
import "@duskmoon-dev/el-breadcrumbs/register";
import "@duskmoon-dev/el-menu/register";
import "@duskmoon-dev/el-navbar/register";
import "@duskmoon-dev/el-pagination/register";
import "@duskmoon-dev/el-tabs/register";
import "@duskmoon-dev/el-table/register";
import "@duskmoon-dev/el-markdown/register";

// Clipboard functionality
function fallbackCopyTextToClipboard(text) {
  var textArea = document.createElement("textarea");
  textArea.value = text;
  
  // Avoid scrolling to bottom
  textArea.style.top = "0";
  textArea.style.left = "0";
  textArea.style.position = "fixed";

  document.body.appendChild(textArea);
  textArea.focus();
  textArea.select();

  try {
    var successful = document.execCommand('copy');
    var msg = successful ? 'successful' : 'unsuccessful';
    console.log('Fallback: Copying text command was ' + msg);
  } catch (err) {
    console.error('Fallback: Oops, unable to copy', err);
  }

  document.body.removeChild(textArea);
}

window.copyTextToClipboard = function(text) {
  if (!navigator.clipboard) {
    fallbackCopyTextToClipboard(text);
    return;
  }
  navigator.clipboard.writeText(text).then(function() {
    console.log('Async: Copying to clipboard was successful!');
  }, function(err) {
    console.error('Async: Could not copy text: ', err);
  });
};

window.showCopyFeedback = function(element) {
  const originalContent = element.innerHTML;
  element.innerHTML = '<span class="text-success">✓</span>';
  setTimeout(() => {
    element.innerHTML = originalContent;
  }, 1000);
};
