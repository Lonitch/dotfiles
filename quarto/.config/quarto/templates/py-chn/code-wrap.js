export function wrap_code() {
  // Find all <div> elements with class "sourceCode" that are not wrapped in <details>
  const unwrapped = document.querySelectorAll(
    "div.sourceCode:not(details > div.sourceCode)",
  );
  console.log(unwrapped[0]);
  // Loop through the unwrapped code blocks
  unwrapped.forEach((codeBlockDiv) => {
    // Create a new <details> element
    const detailsElement = document.createElement("details");
    const summaryElement = document.createElement("summary");
    const elemStr = codeBlockDiv.outerHTML.split("code-summary:")[1];
    if (elemStr) {
      summaryElement.textContent = elemStr.split("<")[0].trim();
    } else {
      summaryElement.textContent = "Show code";
    }
    detailsElement.appendChild(summaryElement);
    // Move the <div> with class "sourceCode" inside the <details> element
    const new_block = codeBlockDiv.cloneNode(true);
    detailsElement.appendChild(new_block);
    // Replace the original <div> with the wrapped <details> element
    codeBlockDiv.replaceWith(detailsElement);
  });
}
