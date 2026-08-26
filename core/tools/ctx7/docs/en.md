## Package Information

- **Name:** Context7
- **Tags:** ai, docs, mcp
- **Project:** https://context7.com
- **Source:** https://github.com/upstash/context7
- **Dependencies:** nodejs

## What is it?

Context7 Platform -- Up-to-date code documentation for LLMs and AI code editors

## How to use it?

### CLI Commands

- `ctx7 library <name> <query>`: Searches the Context7 index by library name and returns matching libraries with their IDs.
- `ctx7 docs <libraryId> <query>`: Retrieves documentation for a library using a Context7-compatible library ID (e.g., `/mongodb/docs`, `/vercel/next.js`).

### MCP Tools

- `resolve-library-id`: Resolves a general library name into a Context7-compatible library ID.
  - `query` (required): The user's question or task (used to rank results by relevance)
  - `libraryName` (required): The name of the library to search for
- `query-docs`: Retrieves documentation for a library using a Context7-compatible library ID.
  - `libraryId` (required): Exact Context7-compatible library ID (e.g., `/mongodb/docs`, `/vercel/next.js`)
  - `query` (required): The question or task to get relevant documentation for

## More Documentation

- [CLI Reference](https://context7.com/docs/clients/cli) - Full CLI documentation
- [MCP Clients](https://context7.com/docs/resources/all-clients) - Manual MCP installation for 30+ clients
- [Adding Libraries](https://context7.com/docs/adding-libraries) - Submit your library to Context7
- [Troubleshooting](https://context7.com/docs/resources/troubleshooting) - Common issues and solutions
- [API Reference](https://context7.com/docs/api-guide) - REST API documentation
- [Developer Guide](https://context7.com/docs/resources/developer) - Run Context7 MCP locally

## Packages

- [`@upstash/context7-mcp`](https://www.npmjs.com/package/@upstash/context7-mcp) - MCP server
- [`ctx7`](https://www.npmjs.com/package/ctx7) - CLI
- [`@upstash/context7-sdk`](https://www.npmjs.com/package/@upstash/context7-sdk) - TypeScript SDK
- [`@upstash/context7-tools-ai-sdk`](https://www.npmjs.com/package/@upstash/context7-tools-ai-sdk) - Vercel AI SDK tools
- [`@upstash/context7-pi`](https://www.npmjs.com/package/@upstash/context7-pi) - pi.dev extension

## Disclaimer

1- Context7 projects are community-contributed and while we strive to maintain high quality, we cannot guarantee the accuracy, completeness, or security of all library documentation. Projects listed in Context7 are developed and maintained by their respective owners, not by Context7. If you encounter any suspicious, inappropriate, or potentially harmful content, please use the "Report" button on the project page to notify us immediately. We take all reports seriously and will review flagged content promptly to maintain the integrity and safety of our platform. By using Context7, you acknowledge that you do so at your own discretion and risk.

2- This repository hosts the MCP server’s source code. The supporting components — API backend, parsing engine, and crawling engine — are private and not part of this repository.

## 🤝 Connect with Us

Stay updated and join our community:

- 📢 Follow us on [X](https://x.com/context7ai) for the latest news and updates
- 🌐 Visit our [Website](https://context7.com)
- 💬 Join our [Discord Community](https://upstash.com/discord)

## 📺 Context7 In Media

- [Better Stack: "Free Tool Makes Cursor 10x Smarter"](https://youtu.be/52FC3qObp9E)
- [Cole Medin: "This is Hands Down the BEST MCP Server for AI Coding Assistants"](https://www.youtube.com/watch?v=G7gK8H6u7Rs)
- [Income Stream Surfers: "Context7 + SequentialThinking MCPs: Is This AGI?"](https://www.youtube.com/watch?v=-ggvzyLpK6o)
- [Julian Goldie SEO: "Context7: New MCP AI Agent Update"](https://www.youtube.com/watch?v=CTZm6fBYisc)
- [JeredBlu: "Context 7 MCP: Get Documentation Instantly + VS Code Setup"](https://www.youtube.com/watch?v=-ls0D-rtET4)
- [Income Stream Surfers: "Context7: The New MCP Server That Will CHANGE AI Coding"](https://www.youtube.com/watch?v=PS-2Azb-C3M)
- [AICodeKing: "Context7 + Cline & RooCode: This MCP Server Makes CLINE 100X MORE EFFECTIVE!"](https://www.youtube.com/watch?v=qZfENAPMnyo)
- [Sean Kochel: "5 MCP Servers For Vibe Coding Glory (Just Plug-In & Go)"](https://www.youtube.com/watch?v=LqTQi8qexJM)

## 📄 License

MIT

## Notes

- Supported platforms: **termux, ubuntu, wsl**.
- Termux uses platform-specific installers; Ubuntu/WSL use official channels.
- Spanish (when available): `core show ctx7:es`.
