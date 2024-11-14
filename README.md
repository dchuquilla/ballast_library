# Ballast Library Project

This project is a library management system with a backend built using Ruby on Rails and a frontend built using React.

In this particular case Book copies are borrowed by members and managed by librarians. Members can borrow and return book copies, while librarians can manage books, and book copies.

Endpoints are documented using Swagger and are grouped by Member and Librarian roles.

Authentication is implemented with JWT and devise for user management.

Authorization is implemented with Policy Object pattern.

## Technologies Used

- **Backend**: Ruby on Rails 3.1.2
- **Frontend**: React with Node.js 20
- **Database**: PostgreSQL

## Getting Started

### Prerequisites

- Docker
- Docker Compose
- Git

### Clone the Repository

```sh
git clone https://github.com/yourusername/ballast-library.git
cd ballast-library
```

Running the Application with Docker

### 1. Build and Start the Containers

```sh
docker-compose up --build -d
```

### 2. Access the Application

- Backend: The Rails server will be running at `http://127.0.0.1:3000`
- API Documentation: The Swagger documentation will be available at `http://127.0.0.1:3000/api-docs/index.html`
- Frontend: The React development server will be running at `http://127.0.0.1:3001`

### Stopping the Containers

```sh
docker-compose down
```

## Running Tests

### Backend

To run the backend tests, use the following command:
```sh
docker-compose exec backend rspec
```

## Demo Users

- **Member**:
  - Email: member@example.com
  - Password: password
- **Librarian**:
  - Email: librarian@example.com
  - Password: password

## Additional Information

- **Backend:** The backend is configured to use PostgreSQL. Ensure that the database configuration in `backend/config/database.yml` matches your setup.
- **Frontend:** The frontend is configured to run on port 3001 to avoid conflicts with the backend.
