// Get the URL and strip the protocol from it.
var git_url = document.getElementById('url_box_clippy').innerHTML;
git_url = git_url.replace('https://', '');

// Create our 'Clone Now' span element
var clone_node = document.createElement('span');
clone_node.id = 'clippy_tooltip_url_box_clippy';
clone_node.setAttribute('class', 'clippy-tooltip tooltipped');
clone_node.setAttribute('original-title', 'Clone now'); 

// Create the inner a element
var link_node = document.createElement('a');
link_node.href = 'mitosis://' +  git_url;
link_node.innerHTML = "Clone Now";

// Add the link to the span element
clone_node.appendChild(link_node);

// Put the span element into place
var url_box = document.getElementById("url_box");
var accessable_text = document.getElementById("url_box").lastChild.previousSibling;
url_box.insertBefore(clone_node, accessable_text);