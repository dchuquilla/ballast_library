# Ballast Library Project

This project is a library management system with a backend built using Ruby on Rails and a frontend built using React.

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
docker-compose up --build
```

### 2. Access the Application

- Backend: The Rails server will be running at `http://127.0.0.1:3000`
- Frontend: The React development server will be running at `http://127.0.0.1:3001`

Stopping the Containers

```sh
docker-compose down
```

## Additional Information

- **Backend:** The backend is configured to use PostgreSQL. Ensure that the database configuration in `backend/config/database.yml` matches your setup.
- **Frontend:** The frontend is configured to run on port 3001 to avoid conflicts with the backend.
