import Foundation
import Testing
import MCP
@testable import NetNewsWireMCPLib

// MARK: - Test Helpers

func makeArticle(
    id: String = "art-1",
    feedID: String = "https://example.com/feed.xml",
    title: String? = "Test Article",
    url: String? = "https://example.com/post",
    externalURL: String? = nil,
    summary: String? = nil,
    contentHTML: String? = nil,
    contentText: String? = nil,
    datePublished: Double? = 1700000000,
    starred: Bool = false,
    read: Bool = true,
    dateArrived: Double = 1700000000,
    authors: String? = nil
) -> ArticleWithStatus {
    ArticleWithStatus(
        articleID: id,
        feedID: feedID,
        uniqueID: id,
        title: title,
        contentHTML: contentHTML,
        contentText: contentText,
        url: url,
        externalURL: externalURL,
        summary: summary,
        imageURL: nil,
        bannerImageURL: nil,
        datePublished: datePublished,
        dateModified: nil,
        searchRowID: nil,
        markdown: nil,
        authors: authors,
        read: read,
        starred: starred,
        dateArrived: dateArrived
    )
}

// MARK: - Existing Formatter Tests

@Test func testFormatDate() {
    let timestamp: Double = 1700000000  // 2023-11-14
    let result = Formatters.formatDate(timestamp)
    #expect(result.contains("2023"))
    #expect(result.contains("11"))
}

@Test func testFormatDateNil() {
    #expect(Formatters.formatDate(nil) == "-")
    #expect(Formatters.formatDate(0) == "-")
}

@Test func testShortDate() {
    let timestamp: Double = 1700000000
    let result = Formatters.shortDate(timestamp)
    #expect(result.contains("2023"))
}

@Test func testEscapeTableCell() {
    #expect(Formatters.escapeTableCell("hello | world") == "hello \\| world")
    #expect(Formatters.escapeTableCell(nil) == "-")
}

@Test func testTruncate() {
    #expect(Formatters.truncate(nil) == "-")
    #expect(Formatters.truncate("") == "-")
    #expect(Formatters.truncate("short") == "short")
    let long = String(repeating: "a", count: 100)
    let truncated = Formatters.truncate(long, maxLength: 10)
    #expect(truncated == "aaaaaaaaaa...")
    #expect(truncated.count == 13)
}

@Test func testFormatCounts() {
    let result = Formatters.formatCounts(account: "Test", total: 100, starred: 10, unread: 5)
    #expect(result.contains("Test"))
    #expect(result.contains("100"))
    #expect(result.contains("10"))
    #expect(result.contains("5"))
}

// MARK: - formatArticleTable Tests

@Test func testFormatArticleTableHeaders() {
    let articles = [makeArticle()]
    let result = Formatters.formatArticleTable(articles, title: "# Test\n")
    #expect(result.contains("| Article ID |"))
    #expect(result.contains("| Title |"))
    #expect(result.contains("| Feed |"))
    #expect(result.contains("| Date |"))
    #expect(result.contains("| Starred |"))
    #expect(result.contains("| URL |"))
}

@Test func testFormatArticleTableRowContent() {
    let article = makeArticle(
        id: "abc-123",
        feedID: "https://example.com/feed.xml",
        title: "My Post",
        url: "https://example.com/post",
        datePublished: 1700000000,
        starred: true
    )
    let result = Formatters.formatArticleTable([article], title: "# Test\n")
    #expect(result.contains("abc-123"))
    #expect(result.contains("My Post"))
    #expect(result.contains("https://example.com/feed.xml"))
    #expect(result.contains("2023"))
    #expect(result.contains("Yes"))
    #expect(result.contains("https://example.com/post"))
}

@Test func testFormatArticleTableEmpty() {
    let result = Formatters.formatArticleTable([], title: "# Empty\n")
    #expect(result.contains("No articles found."))
    #expect(result.contains("Total: 0 articles"))
}

@Test func testFormatArticleTablePipeEscaping() {
    let article = makeArticle(id: "id|with|pipes", title: "Title | Special")
    let result = Formatters.formatArticleTable([article], title: "# Test\n")
    #expect(result.contains("id\\|with\\|pipes"))
    #expect(result.contains("Title \\| Special"))
}

@Test func testFormatArticleTableTotalCount() {
    let articles = [makeArticle(id: "1"), makeArticle(id: "2"), makeArticle(id: "3")]
    let result = Formatters.formatArticleTable(articles, title: "# Test\n")
    #expect(result.contains("Total: 3 articles"))
}

@Test func testFormatArticleTableFallbackToExternalURL() {
    let article = makeArticle(url: nil, externalURL: "https://external.com")
    let result = Formatters.formatArticleTable([article], title: "# Test\n")
    #expect(result.contains("https://external.com"))
}

@Test func testFormatArticleTableFallbackToDateArrived() {
    let article = makeArticle(datePublished: nil, dateArrived: 1700000000)
    let result = Formatters.formatArticleTable([article], title: "# Test\n")
    #expect(result.contains("2023"))
}

// MARK: - formatArticleDetail Tests

@Test func testFormatArticleDetailAllFields() {
    let article = makeArticle(
        id: "detail-1",
        feedID: "https://example.com/feed.xml",
        title: "Full Article",
        url: "https://example.com/post",
        externalURL: "https://external.com/post",
        summary: "A summary of the article.",
        contentHTML: "<p>Hello world</p>",
        datePublished: 1700000000,
        starred: true,
        read: false,
        dateArrived: 1700000000
    )
    let authors = [
        Author(authorID: "a1", name: "Alice", url: nil, avatarURL: nil, emailAddress: nil),
        Author(authorID: "a2", name: "Bob", url: nil, avatarURL: nil, emailAddress: nil),
    ]
    let result = Formatters.formatArticleDetail(article, authors: authors)
    #expect(result.contains("`detail-1`"))
    #expect(result.contains("Full Article"))
    #expect(result.contains("https://example.com/feed.xml"))
    #expect(result.contains("https://example.com/post"))
    #expect(result.contains("https://external.com/post"))
    #expect(result.contains("Starred**: Yes"))
    #expect(result.contains("Read**: No"))
    #expect(result.contains("Alice, Bob"))
    #expect(result.contains("A summary of the article."))
    #expect(result.contains("<p>Hello world</p>"))
}

@Test func testFormatArticleDetailOptionalFieldsOmitted() {
    let article = makeArticle(
        title: nil,
        url: nil,
        externalURL: nil,
        summary: nil,
        contentHTML: nil,
        contentText: nil
    )
    let result = Formatters.formatArticleDetail(article, authors: [])
    #expect(!result.contains("**Title**"))
    #expect(!result.contains("**URL**"))
    #expect(!result.contains("**External URL**"))
    #expect(!result.contains("## Summary"))
    #expect(!result.contains("## Content"))
}

@Test func testFormatArticleDetailContentTextFallback() {
    let article = makeArticle(contentHTML: nil, contentText: "Plain text content")
    let result = Formatters.formatArticleDetail(article, authors: [])
    #expect(result.contains("## Content\n"))
    #expect(result.contains("Plain text content"))
    #expect(!result.contains("## Content (HTML)"))
}

@Test func testFormatArticleDetailNoAuthors() {
    let article = makeArticle()
    let result = Formatters.formatArticleDetail(article, authors: [])
    #expect(!result.contains("**Authors**"))
}

// MARK: - formatFeedTable Tests

@Test func testFormatFeedTableStructure() {
    let feeds = [
        FeedInfo(title: "Daring Fireball", xmlUrl: "https://df.com/feed", htmlUrl: "https://df.com", folder: "Tech"),
        FeedInfo(title: "Kottke", xmlUrl: "https://kottke.org/feed", htmlUrl: nil, folder: nil),
    ]
    let result = Formatters.formatFeedTable(feeds)
    #expect(result.contains("# Subscribed Feeds"))
    #expect(result.contains("| Feed |"))
    #expect(result.contains("| Folder |"))
    #expect(result.contains("| URL |"))
    #expect(result.contains("Daring Fireball"))
    #expect(result.contains("Tech"))
    #expect(result.contains("https://df.com/feed"))
    #expect(result.contains("Kottke"))
    #expect(result.contains("Total: 2 feeds"))
}

@Test func testFormatFeedTableEmpty() {
    let result = Formatters.formatFeedTable([])
    #expect(result.contains("No feeds found."))
    #expect(result.contains("Total: 0 feeds"))
}

// MARK: - formatAccountList Tests

@Test func testFormatAccountListWithOPML() {
    let accounts = [
        NNWAccount(name: "2_iCloud", path: "/path/to/icloud", dbPath: "/path/to/icloud/DB.sqlite3", opmlPath: "/path/to/icloud/Subscriptions.opml"),
    ]
    let result = Formatters.formatAccountList(accounts)
    #expect(result.contains("**2_iCloud**"))
    #expect(result.contains("/path/to/icloud"))
    #expect(result.contains("OPML: Yes"))
}

@Test func testFormatAccountListWithoutOPML() {
    let accounts = [
        NNWAccount(name: "OnMyMac", path: "/path/to/local", dbPath: "/path/to/local/DB.sqlite3", opmlPath: nil),
    ]
    let result = Formatters.formatAccountList(accounts)
    #expect(result.contains("**OnMyMac**"))
    #expect(result.contains("OPML: No"))
}

// MARK: - ToolHandlers Tests

@Test func testRequireStringThrowsWhenMissing() {
    let args: [String: Value] = [:]
    #expect(throws: NNWError.self) {
        _ = try ToolHandlers.requireString(args, key: "article_id")
    }
}

@Test func testRequireStringReturnsValue() throws {
    let args: [String: Value] = ["article_id": .string("abc-123")]
    let result = try ToolHandlers.requireString(args, key: "article_id")
    #expect(result == "abc-123")
}

// MARK: - OPMLParser Tests

@Test func testOPMLParserBasic() {
    let opml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <opml version="2.0">
        <body>
            <outline text="Tech" title="Tech">
                <outline type="rss" title="Daring Fireball" xmlUrl="https://daringfireball.net/feeds/main" htmlUrl="https://daringfireball.net"/>
                <outline type="rss" title="Kottke" xmlUrl="https://feeds.kottke.org/main" htmlUrl="https://kottke.org"/>
            </outline>
            <outline type="rss" title="No Folder Feed" xmlUrl="https://example.com/feed.xml"/>
        </body>
        </opml>
        """
    let parser = OPMLParser(data: Data(opml.utf8))
    let feeds = parser.parse()

    #expect(feeds.count == 3)

    #expect(feeds[0].title == "Daring Fireball")
    #expect(feeds[0].xmlUrl == "https://daringfireball.net/feeds/main")
    #expect(feeds[0].htmlUrl == "https://daringfireball.net")
    #expect(feeds[0].folder == "Tech")

    #expect(feeds[1].title == "Kottke")
    #expect(feeds[1].xmlUrl == "https://feeds.kottke.org/main")
    #expect(feeds[1].folder == "Tech")

    #expect(feeds[2].title == "No Folder Feed")
    #expect(feeds[2].xmlUrl == "https://example.com/feed.xml")
    // A top-level feed after a folder closes must NOT inherit the folder.
    #expect(feeds[2].folder == nil)
}

@Test func testOPMLParserSiblingFolders() {
    let opml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <opml version="2.0">
        <body>
            <outline text="Tech" title="Tech">
                <outline type="rss" title="Daring Fireball" xmlUrl="https://df.net/feed"/>
            </outline>
            <outline text="News" title="News">
                <outline type="rss" title="AP" xmlUrl="https://ap.org/feed"/>
            </outline>
        </body>
        </opml>
        """
    let feeds = OPMLParser(data: Data(opml.utf8)).parse()
    #expect(feeds.count == 2)
    #expect(feeds[0].folder == "Tech")
    #expect(feeds[1].folder == "News")
}

@Test func testOPMLParserNestedFolders() {
    let opml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <opml version="2.0">
        <body>
            <outline text="Outer" title="Outer">
                <outline text="Inner" title="Inner">
                    <outline type="rss" title="Deep Feed" xmlUrl="https://deep.example.com/feed"/>
                </outline>
                <outline type="rss" title="Outer Feed" xmlUrl="https://outer.example.com/feed"/>
            </outline>
        </body>
        </opml>
        """
    let feeds = OPMLParser(data: Data(opml.utf8)).parse()
    #expect(feeds.count == 2)
    // Nearest enclosing folder wins.
    #expect(feeds[0].folder == "Inner")
    // After the nested folder closes, its parent folder is restored.
    #expect(feeds[1].folder == "Outer")
}

@Test func testOPMLParserFeedBeforeFolder() {
    let opml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <opml version="2.0">
        <body>
            <outline type="rss" title="Loose Feed" xmlUrl="https://loose.example.com/feed"/>
            <outline text="Tech" title="Tech">
                <outline type="rss" title="Folded" xmlUrl="https://folded.example.com/feed"/>
            </outline>
        </body>
        </opml>
        """
    let feeds = OPMLParser(data: Data(opml.utf8)).parse()
    #expect(feeds.count == 2)
    #expect(feeds[0].folder == nil)
    #expect(feeds[1].folder == "Tech")
}

@Test func testOPMLParserEmptyBody() {
    let opml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <opml version="2.0">
        <body>
        </body>
        </opml>
        """
    let parser = OPMLParser(data: Data(opml.utf8))
    let feeds = parser.parse()
    #expect(feeds.isEmpty)
}

@Test func testOPMLParserFallsBackToText() {
    let opml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <opml version="2.0">
        <body>
            <outline type="rss" text="Text Title" xmlUrl="https://example.com/feed.xml"/>
        </body>
        </opml>
        """
    let parser = OPMLParser(data: Data(opml.utf8))
    let feeds = parser.parse()
    #expect(feeds.count == 1)
    #expect(feeds[0].title == "Text Title")
}
