# OnBaseball

A Ruby on Rails application for baseball fans to log and share their thoughts on MLB games. Built with modern Rails 8.0.2, MongoDB, and real-time MLB API integration.

## Features

### Game Display & Navigation
- View live MLB games with real-time scores and game status
- Historical game viewing with date navigation (date picker defaults to current day)
- Game status indicators: upcoming (with start times), live (with inning and score), completed (with final score)
- Starting pitcher matchups when available
- Detailed game pages showing community discussion

### User Interaction
- User authentication system with Devise (sign up, sign in, profile management)
- Log personal thoughts and observations about games (up to 500 characters)
- Multiple entries per game support
- Delete your own entries
- Visual indicators when you have existing thoughts on a game
- Editable display names separate from email addresses

### Community Features
- View other users' thoughts on games in chronological order
- Like/dislike system for community engagement with vote tracking
- User profiles with game thought history and statistics
- User search functionality by display name
- Follow/unfollow system with follower/following counts
- Real-time notification system for user interactions

### Game Context Tracking
- Automatic detection of when thoughts are posted (before/during/after game)
- Visual context badges showing game timing (e.g., "Top 3rd", "Before Game")
- Inning and score tracking for thoughts posted during live games
- Context displays on both game detail and user profile pages

### User Experience
- Responsive design that works on mobile and desktop
- Professional navigation with search and profile access
- Real-time game data integration via MLB Stats API
- PWA (Progressive Web App) support with manifest and service worker
- Modern UI with Tailwind CSS styling

## Technology Stack

- **Ruby** 3.2.0
- **Rails** 8.0.2
- **Database**: MongoDB with Mongoid ORM
- **Authentication**: Devise with bcrypt
- **External API**: MLB Stats API for live game data
- **HTTP Client**: HTTParty for API integration
- **CSS Framework**: Tailwind CSS v4.1.10
- **JavaScript**: Stimulus.js with importmaps
- **Development Server**: Puma on localhost:3000
- **Deployment**: Kamal with Docker support
- **Pagination**: Kaminari for MongoDB

## Project Structure

### Models
- **User**: Authentication, profiles, follow relationships, notifications
- **GameThought**: User thoughts on games with voting system, game context tracking (before/during/after), inning details, and timestamps
- **Vote**: Like/dislike system for game thoughts
- **Follow**: User follow relationships
- **Notification**: Real-time notification system

### Controllers
- **HomeController**: Main game listing and date navigation
- **GameThoughtsController**: CRUD operations for thoughts and voting
- **GamesController**: Individual game detail pages
- **UsersController**: User profiles, search, and follow management
- **NotificationsController**: Notification management
- **FollowsController**: Follow/unfollow functionality

### Services
- **MlbApiService**: Real-time MLB game data fetching and game context determination (before/during/after game status)

### Key Features for Developers
- Real-time MLB game data fetching via HTTParty
- MongoDB document-based storage with Mongoid
- User authentication and authorization with Devise
- CRUD operations for game thoughts with validation
- Voting system with atomic updates
- User search with text indexing
- Follow system with bidirectional relationships
- Notification system for user interactions
- PWA support for mobile app-like experience

### JavaScript Features
- Stimulus.js controllers for interactive components
- Real-time game status updates
- Dynamic form handling

## Setup Instructions

### Prerequisites
- Ruby 3.2.0+
- MongoDB 4.4+
- Node.js (for Tailwind CSS compilation)
- Internet connection for MLB API data

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone [your-repo-url]
   cd onbaseball
   ```

2. **Install Ruby dependencies**
   ```bash
   bundle install
   ```

3. **Start MongoDB service**
   ```bash
   # On macOS with Homebrew
   brew services start mongodb/brew/mongodb-community
   
   # On Ubuntu/Debian
   sudo systemctl start mongod
   ```

4. **Set up the database**
   ```bash
   # MongoDB doesn't require migrations, but you can run this if you have seed data
   rails db:seed
   ```

5. **Compile assets (if needed)**
   ```bash
   # For Tailwind CSS compilation
   rails assets:precompile
   ```

6. **Start the Rails server**
   ```bash
   rails server
   ```

7. **Visit the application**
   Open your browser and go to `http://localhost:3000`

## Development

### Environment Setup
The application uses Rails 8.0.2 with the following key configurations:
- MongoDB as the primary database (no ActiveRecord)
- Devise for authentication
- Tailwind CSS for styling
- Stimulus.js for JavaScript interactions
- Kamal for deployment

### Testing
```bash
# Run all tests
rails test

# Run specific test files
rails test test/models/user_test.rb
rails test test/controllers/game_thoughts_controller_test.rb
```

### Code Quality
```bash
# Run RuboCop for code style checking
bundle exec rubocop

# Run Brakeman for security analysis
bundle exec brakeman
```

## API Integration

The application integrates with the MLB Stats API to fetch:
- Daily game schedules
- Live game scores and status
- Starting pitcher information
- Game timing and inning details

### API Endpoints Used
- `https://statsapi.mlb.com/api/v1/schedule` - Game schedules
- Game data includes team information, scores, status, and probable pitchers

## Deployment

### Docker Support
The application includes a production-ready Dockerfile for containerized deployment.

### Kamal Deployment
Configure deployment settings in `config/deploy.yml`:
- Set your server IP addresses
- Configure SSL and domain settings
- Set up registry credentials
- Configure environment variables

```bash
# Deploy to production
bin/kamal deploy

# Access Rails console
bin/kamal console

# View logs
bin/kamal logs
```

## Contributing

This is a personal learning project, but suggestions and feedback are welcome!

### Development Guidelines
- Follow Rails conventions
- Use RuboCop for code style consistency
- Write tests for new features
- Keep commits atomic and well-described

## License

This project is for educational purposes.

## Support

For issues or questions, please check the existing issues or create a new one in the repository.
