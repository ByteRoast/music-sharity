const fs = require('fs');
const { marked } = require('marked');

function convertToHTML(mdFile, title, outputFile) {
  const markdown = fs.readFileSync(mdFile, 'utf8');
  const content = marked.parse(markdown);

  const html = `<!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>${title}</title>
      <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/github-markdown-css@5/github-markdown.min.css">
      <style>
        body {
          max-width: 900px;
          margin: 40px auto;
          padding: 20px;
          background: #f5f5f5;
          font-family: -apple-system,BlinkMacSystemFont,"Segoe UI","Noto Sans",Helvetica,Arial,sans-serif,"Apple Color Emoji","Segoe UI Emoji";
        }
        .markdown-body {
          background: white;
          padding: 40px;
          border-radius: 8px;
          box-shadow: 0 2px 10px rgba(0,0,0,0.1);
          color: #000000 !important;
        }
        .back-link {
          display: inline-block;
          margin-bottom: 20px;
          color: #1976d2;
          text-decoration: none;
          font-weight: 500;
        }
        .back-link:hover {
          text-decoration: underline;
        }
        .markdown-body table {
          border-collapse: collapse;
          width: 100%;
          margin: 20px 0;
        }
        .markdown-body table th,
        .markdown-body table td {
          border: 1px solid #ddd;
          padding: 12px;
          text-align: left;
        }
        .markdown-body table th {
          background-color: #f5f5f5;
          font-weight: 600;
        }
        .markdown-body table tr {
          background-color: #ffffff !important;
        }
        .markdown-body table tr:hover {
          background-color: #f9f9f9;
        }
      </style>
    </head>
    <body>
      <a href="/docs.html" class="back-link">← Back to Documentation</a>
      <div class="markdown-body">
        ${content}
      </div>
    </body>
    </html>
  `;

  fs.writeFileSync(outputFile, html, 'utf8');
  console.log(`Generated ${outputFile}`);
}

// Convert LICENSE.md and PRIVACY.md
convertToHTML('LICENSE.md', 'Music Sharity - License', 'build/web/license.html');
convertToHTML('PRIVACY.md', 'Music Sharity - Privacy Policy', 'build/web/privacy.html');
