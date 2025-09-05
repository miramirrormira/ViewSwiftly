# ViewSwiftly

Welcome to ViewSwiftly, a framework designed to help you create paginated list views. It automates page requests as users scroll down the list. This framework is written in Swift.

## Features
### Pagination Features
1. Automated paged data request
2. FetchedItemsStrategy allows prefetching item assets immediately after the new items are fetched
3. RefreshStrategy allows customizable action upon refreshing the list
4. Includes these list styles: v-stack, h-stack, grid

### FetchResponseView feature
1. allow fast UI development through automating the networking and data flow
2. You provide the networking endpoint, and how you want to render the fetched data. ViewSwift does the rest.


## Installation
### Swift Package Manager
```
dependencies: [
    .package(url: "github.com/miramirrormira/ViewSwiftly.git", from: "1.0.0")
]
```

## Examples
### FetchResponseView

1. create network request
```
let moviePosterConfig = NetworkConfiguration(host: "image.tmdb.org", scheme: "https", apiBaseRoute: "t/p/original")
let endpoint = Endpoint(path: "/8cdWjvZQUExUUTzyp4t6EDMubfO.jpg", method: .get)
let requestable = URLRequestRequest(urlRequestFactory: EndpointURLRequestFactory(networkConfiguration: moviePosterConfig, endpoint: endpoint))
```

2. create view model, 

specify the type of the Response, in this example it is Data
```
let vm = FetchResponseViewModel<Data>(requestable: requestable.eraseToAnyRequestable())
```

3. create FetchResponseView in the computed body property in a SwiftUI view

```
FetchResponseView(with: viewModel.eraseToAnyViewModel(), content: { user in
    Text(user.username)
}, errorView: { error in
    Text("[user]Deleted")
})
```

#### What if I am not using RESTful API?
you can replace the requestable from the above example with any customized version. Just make a class that conforms to Requestable, then implement your own version of the networking request functions

##### Firebase example

```
public class FirebaseGetDocumentObjectRequest<T: Decodable & InitializableFromDictionary>: Requestable {
    
    public typealias Response = T
    
    var documentReference: DocumentReference
    public init(documentReference: DocumentReference) {
        self.documentReference = documentReference
    }
    
    public func request() async throws -> T {
        let snapshot = try await documentReference.getDocument()
        guard var data = snapshot.data() else {
            throw FirebaseErrors.cannotGetDataFromSnapshot
        }
        data["id"] = snapshot.documentID
        guard let object = T.init(dictionary: data) else {
            throw FirebaseErrors.cannotInitializeObject
        }
        return object
    }
}
```

1. create firebase request
```
let docRef = Firebase.firestore().collection("YOUR_COLLECTION").document(YOUR_DOCUMENT_ID)
let docReq = FirebaseGetDocumentObjectRequest(documentReference: docRef)
```

2. create view model, 

specify the type of the Response, in this example it is Data
```
let vm = FetchResponseViewModel<YOUR_OBJECT_TYPE>(requestable: docReq.eraseToAnyRequestable())
```

3. create FetchResponseView in the computed body property in a SwiftUI view
```
FetchResponseView(with: viewModel.eraseToAnyViewModel(), content: { object in
    Text(object.id)
}, errorView: { error in
    Text(error.localizedDescription)
})
```

### PaginatedLazyVStack/PaginatedLazyHStack

1. create paginated network request 
```
let networkingConfig = NetworkConfiguration(host: "api.themoviedb.org", scheme: "https", apiBaseRoute: "3")
let popularMoviesEndpoint = Endpoint(path: "movie/popular", method: .get, queryParameters: ["language" : "en-US", "api_key": "YOUR_API_KEY"])
```

1.1 (optional) transform the API response to an array of fetched items
```
let transformMoviePage: (MoviePage) -> [Movie] = { moviePage in
    moviePage.results.map { movie in
        Movie(title: movie.title, page: moviePage.page, poster_path: movie.poster_path)
    }
}
```

2. create PaginationQueryStrategy

paginationQueryStrategy is used to update the pagination parameter in the RESTful API url. For example: https://www.moviedb.com/popular/page=1. If the pagination API is page base and the parameter to request a certain page is "page", then you can use the following:
```
let paginationQueryStrategy = PageBasedQueryStrategy(pageKey: "page")
```

3. create PaginatedItemsViewModel 
```
let popularMoviesViewModel: PaginatedItemsViewModel<Movie> = .init(networkConfiguration: networkingConfig,
                                                                endpoint: popularMoviesEndpoint,
                                                                paginationQueryStrategy: paginationQueryStrategy,
                                                                transform: transformMoviePage)
```
4. create PaginatedLazyVStack in the computed body property in a SwiftUI view
```
PaginatedLazyVStack(id: "movie_list", viewModel: popularMoviesViewModel) { movie in
    MovieRow(viewModel: MovieRowViewModel(movie: movie))
}                                                             

```