import Foundation
import MCP

public enum ToolHandlers {

    // MARK: - All Tools

    public static let allTools: [Tool] = [
        listAccountsTool,
        listFeedsTool,
        listStarredArticlesTool,
        listRecentArticlesTool,
        getArticleTool,
        searchArticlesTool,
        getArticleCountTool,
    ]

    // MARK: - Call Routing

    public static func handleCall(
        name: String,
        arguments: [String: Value]?,
        database: NNWDatabase
    ) -> CallTool.Result {
        do {
            let args = arguments ?? [:]
            switch name {
            case "list_accounts":
                return handleListAccounts(database: database)
            case "list_feeds":
                return try handleListFeeds(args: args, database: database)
            case "list_starred_articles":
                return try handleListStarredArticles(args: args, database: database)
            case "list_recent_articles":
                return try handleListRecentArticles(args: args, database: database)
            case "get_article":
                return try handleGetArticle(args: args, database: database)
            case "search_articles":
                return try handleSearchArticles(args: args, database: database)
            case "get_article_count":
                return try handleGetArticleCount(args: args, database: database)
            default:
                return CallTool.Result(
                    content: [.text(text: "Unknown tool: \(name)", annotations: nil, _meta: nil)],
                    isError: true
                )
            }
        } catch {
            return CallTool.Result(
                content: [.text(text: "Error: \(error)", annotations: nil, _meta: nil)],
                isError: true
            )
        }
    }

    // MARK: - Parameter Helpers

    static func requireString(_ args: [String: Value], key: String) throws -> String {
        guard let value = args[key]?.stringValue else {
            throw NNWError.missingParameter(key)
        }
        return value
    }

    /// Largest number of rows any query will return.
    static let maxLimit = 500

    /// Read an optional integer argument, accepting JSON numbers that arrive as
    /// either integers or integral doubles (e.g. `50` or `50.0`).
    static func optionalInt(_ args: [String: Value], key: String) -> Int? {
        guard let value = args[key] else { return nil }
        if let i = value.intValue { return i }
        if let d = value.doubleValue, d == d.rounded() { return Int(d) }
        return nil
    }

    /// Resolve and clamp a `limit` argument into `1...maxLimit`, falling back to
    /// `defaultValue` when absent or non-numeric. Prevents a negative limit
    /// (which SQLite treats as "no limit") or a huge value from dumping the
    /// entire table into a response.
    static func resolveLimit(_ args: [String: Value], default defaultValue: Int) -> Int {
        let raw = optionalInt(args, key: "limit") ?? defaultValue
        return min(max(raw, 1), maxLimit)
    }
}
