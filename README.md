# NASA Data Explorer

Welcome to the NASA Data Explorer project! This Xcode project allows users to search and explore NASA data seamlessly. Below you will find all the necessary information to get started with the project, including how to clone the repository, authentication, and detailed technical implementation.

## Clone Repository

To clone the repository, use the following command:

HTTP:
```bash
git clone https://github.com/mrugama/NASA.git

```

SSH
```bash
git@github.com:mrugama/NASA.git
```

## Authentication
> [!NOTE]
> You do not need to authenticate to explore NASA data.
If you plan to intensively use the APIs, for instance, to support a mobile application, it is recommended to sign up for a [NASA developer key](https://api.nasa.gov/#signUp).

> [!IMPORTANT]
> Once you have your API token, paste it within the EndpointManager token property in the project.

## How It Works
Run the App: Launch the app and you will see a page with a search view.
Search Functionality: Tap on the search bar and start typing. A view with options will appear. You can either press enter to search without applying any filter or select an option to refine your search.
Detail View: Tapping on any grid cell will take you to a detailed page with more information.

## Example Screenshots
Search View    Detail View

## NASA App Technical Implementation
The project is structured in a way to ensure reusability, maintainability, and scalability. Below is a chronological overview of the technical implementation:

1. Understand NASA Services
    - Read documentation
    - Create account
    - Use Postman to preview the response
2. Xcode Project Setup
    - Xcode Project with no storyboard
3. Model Data
    - Identifiable
    - Hashable
    - ViewModel
4. Endpoint Manager
    - URLComponent
    - Token
    - Pagination handler
    - Search option (Title, Photographer, Location)
5. Services for Network Calls
    - Generic for reusability
    - Async/Await concurrency
6. Search Collection View Controller
    - Custom collection view cell
    - Compositional layout
    - Diffable datasource
    - Search Controller
    - Filter option
    - ViewModel
    - Load data from search
    - Prefetch data
    - Image loader
7. Detail ViewController
    - Content views
    - Scroll capability
    - Update Navigation title
    - Animate image based on content offset while scrolling
8. Disk Storage Manager for Caching Images
    - UserDefaults for initial implementation
    - Update to FileManager for a more robust implementation
