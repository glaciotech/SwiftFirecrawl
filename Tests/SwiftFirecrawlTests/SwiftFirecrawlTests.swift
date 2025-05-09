import XCTest
@testable import SwiftFirecrawl

final class SwiftFirecrawlTests: XCTestCase {
   
    func test_basicScrapeOfWebPageFails() async throws {
        let sf = SwiftFirecrawl(apiKey: "invalid")
        do {
            let md = try await sf.scrape(rawUrlString: "https://web.ics.purdue.edu/~gchopra/class/public/pages/webdesign/05_simple.html")
        }
        catch {
            return
        }
        
        XCTFail("No error was thrown")
    }
    
    func test_basicScrapeOfWebPage() async throws {
        
        let apiKey = UserDefaults.standard.string(forKey: "FC_API_KEY")!
        
        let sf = SwiftFirecrawl(apiKey: apiKey)

        let testStringUrl = "https://x.com/rohanpaul_ai/status/1866889287851253880"
        // "https://web.ics.purdue.edu/~gchopra/class/public/pages/webdesign/05_simple.html"
        let md = try await sf.scrape(rawUrlString: testStringUrl)
        print(md)
    }
    
    func test_basicScrapeOfWebPageWithURL() async throws {
        
        let apiKey = UserDefaults.standard.string(forKey: "FC_API_KEY")!
        
        let sf = SwiftFirecrawl(apiKey: apiKey)
        let scrapeUrl = URL(string: "https://web.ics.purdue.edu/~gchopra/class/public/pages/webdesign/05_simple.html")!
        let md = try await sf.scrape(url: scrapeUrl)
        print(md)
    }
    
    func test_basicScrapeOfFlexMLSURL() async throws {
        
        let apiKey = UserDefaults.standard.string(forKey: "FC_API_KEY")!
        
        let sf = SwiftFirecrawl(apiKey: apiKey)

        let testStringUrl = "https://www.redfin.com/AZ/Scottsdale/6420-E-Montreal-Pl-85254/home/27645034"
        //"https://www.flexmls.com/cgi-bin/mainmenu.cgi?cmd=url+other/run_public_link.html&public_link_tech_id=1tz3zo8jzirp&s=12&id=1&san=36486&cid=1"
        // "https://web.ics.purdue.edu/~gchopra/class/public/pages/webdesign/05_simple.html"
        let md = try await sf.scrape(rawUrlString: testStringUrl)
        print(md)
    }
}
