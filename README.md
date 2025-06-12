# OnBaseball

A Ruby on Rails application for baseball fans to log and share their thoughts on MLB games.

## Features

### Game Display & Navigation
- View live MLB games with real-time scores and game status
- Historical game viewing with date navigation (date picker defaults to current day)
- Game status indicators: upcoming (with start times), live (with inning and score), completed (with final score)
- Starting pitcher matchups when available

### User Interaction
- User authentication system (sign up, sign in, profile management)
- Log personal thoughts and observations about games (up to 500 characters)
- Multiple entries per game support
- Delete your own entries
- Visual indicators when you have existing thoughts on a game

### Community Features
- View other users' thoughts on games in chronological order
- Like/dislike system for community engagement
- User profiles with game thought history and statistics
- User search functionality by display name
- Detailed game pages showing community discussion
- Follow other users, and see who's following who

### User Experience
- Responsive design that works on mobile and desktop
- Editable display names separate from email addresses
- Professional navigation with search and profile access
- Real-time game data integration

## Technology Stack

- **Ruby** 3.2.0
- **Rails** 8.0.2
- **Database**: MongoDB with Mongoid ORM
- **Authentication**: Devise with bcrypt
- **External API**: MLB Stats API for live game data
- **HTTP Client**: HTTParty for API integration
- **Development Server**: Puma on localhost:3000

## Setup Instructions

### Prerequisites
- Ruby 3.2.0+
- MongoDB
- Homebrew (for Mac)
- Internet connection for MLB API data

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone [your-repo-url]
   cd onbaseball
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Start MongoDB service**
   ```bash
   brew services start mongodb/brew/mongodb-community
   ```

4. **Set up the database** (if needed)
   ```bash
   # MongoDB doesn't require migrations, but you can run this if you have seed data
   rails db:seed
   ```

5. **Start the Rails server**
   ```bash
   rails server
   ```

6. **Visit the application**
   Open your browser and go to `http://localhost:3000`

## Development

### Project Structure
- **Models**: User, GameThought, Vote
- **Controllers**: Home, GameThoughts, Games, Users
- **Services**: MlbApiService for real-time MLB data
- **Authentication**: Full Devise integration with custom display names

### Key Features for Developers
- Real-time MLB game data fetching
- MongoDB document-based storage
- User authentication and authorization
- CRUD operations for game thoughts
- Voting system with atomic updates
- User search with text indexing

### Testing
```bash
rails test
```

## API Integration

The application integrates with the MLB Stats API to fetch:
- Daily game schedules
- Live game scores and status
- Starting pitcher information
- Game timing and inning details

## Contributing

This is a personal learning project, but suggestions and feedback are welcome!

## License

This project is for educational purposes.
