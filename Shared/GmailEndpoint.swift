import Foundation


struct GmailEndpoint {
  var name: String
  var url: URL
  var responseType: Codable.Type
  var httpMethod: String
  
  static let listFilters = Self(
    name: "list filters",
    url: URL(string: "https://gmail.googleapis.com/gmail/v1/users/me/settings/filters")!,
    responseType: GFilterListResponse.self,
    httpMethod: "GET"
  )
  
  static let createFilter = Self(
    name: "create filters",
    url: URL(string: "https://gmail.googleapis.com/gmail/v1/users/me/settings/filters")!,
    responseType: GFilter.self,
    httpMethod: "POST"
  )
  
  static func deleteFilter(id: String) -> GmailEndpoint {
    return Self(
      name: "delete filters",
      url: URL(string: "https://gmail.googleapis.com/gmail/v1/users/me/settings/filters/\(id)")!,
      responseType: ResponseTypeNone.self,
      httpMethod: "DELETE"
    )
  }
  
  static let listLabels = Self(
    name: "list labels",
    url: URL(string: "https://gmail.googleapis.com/gmail/v1/users/me/labels")!,
    responseType: GLabelListResponse.self,
    httpMethod: "GET"
  )
  
  @discardableResult
  static func call(
    _ endpoint: GmailEndpoint, accessToken: String, withBody body: Any? = nil
  ) async throws -> (Decodable, URLResponse) {
    
    var request = URLRequest(url: endpoint.url)
    request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    request.httpMethod = endpoint.httpMethod
    
    if let body = body {
      request.addValue("application/json", forHTTPHeaderField: "Content-Type")
      
      do {
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
      } catch {
        print("error creating http body for gmail call")
        throw error
      }
    }
    
    let (data, response) = try await URLSession.shared.data(for: request)
    let statusCode = (response as! HTTPURLResponse).statusCode
    
    if statusCode >= 200, statusCode < 300 {
      print("\(endpoint.name) call succeeded")
    } else {
      throw PsyError.gmailCallFailed(message: "\(statusCode) status code")
    }
    
    if endpoint.responseType == ResponseTypeNone.self {
      return ("", response)
    }
    
    let decoder = JSONDecoder()
    let decodedData = try decoder.decode(endpoint.responseType, from: data)
    
    return (decodedData, response)
  }
  
}


struct ResponseTypeNone: Codable {}


// MARK: - GMAIL LABELS

struct GLabelListResponse: Codable {
  var labels: [GLabel]
}

struct GLabel: Codable {
  var id: String
  var name: String
  var type: String
  var messageListVisibility: String?
  var labelListVisibility: String?
  var messagesTotal: Int?
  var messagesUnread: Int?
  var threadsTotal: Int?
  var threadsUnread: Int?
  var color: GLabelColor?
}

struct GLabelColor: Codable {
  var textColor: String?
  var backgroundColor: String?
}

// MARK: - GMAIL FILTERS

/**
 Gmail Filter, see: https://developers.google.com/gmail/api/reference/rest/v1/users.settings.filters
 */

struct GFilterListResponse: Codable {
  var filter: [GFilter]
}

struct GFilter: Codable {
  var id: String
  var criteria: GFilterCriteria?
  var action: GFilterAction?
}

struct GFilterCriteria: Codable {
  var from: String?
  var to: String?
  var subject: String?
  var query: String?
  var negatedQuery: String?
  var hasAttachment: Bool?
  var excludeChats: Bool?
  var size: Int?
  var sizeComparison: String? // enum: unspecified, larger, smaller
}

struct GFilterAction: Codable {
  var addLabelIds: [String]?
  var removeLabelIds: [String]?
  var forward: String?
}
