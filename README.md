# OnBaseball

A Ruby on Rails application for baseball fans to log and share their thoughts on MLB games.

## Features

- View live MLB games with real-time scores and game status
- Log personal thoughts and observations about games
- View other users' thoughts and engage with the community
- Like/dislike system for community engagement
- User profiles and search functionality
- Historical game viewing with date navigation
- Multiple entries per game support

## Technology Stack

- Ruby 3.2.0
- Rails 8.0.2
- MongoDB with Mongoid ORM
- Devise for authentication
- MLB Stats API for live game data
- HTTParty for API integration

## Setup

1. Clone the repository
2. Install dependencies: `bundle install`
3. Start MongoDB service: `brew services start mongodb/brew/mongodb-community`
4. Start the Rails server: `rails server`
5. Visit `http://localhost:3000`

## Requirements

- Ruby 3.2.0+
- MongoDB
- Internet connection for MLB API data

## Development

The application fetches live MLB game data and allows authenticated users to log thoughts, view community discussions, and engage with other baseball fans' perspectives on games.