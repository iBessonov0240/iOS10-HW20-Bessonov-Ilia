import UIKit

enum NetWorkError: Error {
    case networkProblem
    case badRequest
    case badResponce
    case notFound
}

extension NetWorkError: LocalizedError {

    public var errorDescription: String? {
        switch self {
        case .networkProblem: return "No Internet Connection"
        case .badRequest: return "Bad Request: 400"
        case .badResponce: return "Bad Responce"
        case .notFound: return "Not Found: 404"
        }
    }
}

struct Cards: Decodable {
    let cards: [Card]
}

struct Card: Decodable {
    var name: String? = ""
    var manaCost: String? = ""
    var type: String? = ""
    var set: String? = ""
    var colors: [String]? = nil
    var date: Date? = nil
}

func getData(urlRequest: String) {
    let urlRequest = URL(string: urlRequest)
    guard let url = urlRequest else { return }
    URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error as NSError? {
            switch error.code {
            case NSURLErrorNotConnectedToInternet:
                NetWorkError.networkProblem.errorDescription
                print("No Internet Connection")
            case NSURLErrorBadServerResponse:
                NetWorkError.badResponce.errorDescription
                print("Bad Responce")
            case NSURLErrorBadURL:
                NetWorkError.badRequest.errorDescription
                print("Bad Request: 400")
            case NSURLErrorCannotFindHost:
                NetWorkError.notFound.errorDescription
                print("Not Found: 404")
            default:
                print("Error: \(error)")
            }
        } else if let response = response as? HTTPURLResponse, response.statusCode == 200 {
            guard let data = data else { return }
            let dataAsString = String(data: data, encoding: .utf8)
            do {
                let decoder = JSONDecoder()
                let decoded = try decoder.decode(Cards.self, from: data)
                for card in decoded.cards {
                    print("Имя карты: \(card.name ?? "")")
                    print("Тип: \(card.type ?? "")")
                    print("Мановая стоимость: \(card.manaCost ?? "")")
                    print("Название сета: \(card.set ?? "")")
                    print("Цвет: \(card.colors ?? [])")

                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    decoder.dateDecodingStrategy = .formatted(dateFormatter)

                    let formattedDate = dateFormatter.string(from: card.date ?? Date())
                    print("Дата: \(formattedDate)\n")
                }
            } catch {
                print(error)
            }
        }
    }.resume()
}

getData(urlRequest: "https://api.magicthegathering.io/v1/cards?name=Black%20Lotus")
getData(urlRequest: "https://api.magicthegathering.io/v1/cards?name=Opt")
