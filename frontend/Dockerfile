# Use Node.js as the base image
FROM node:20

# Set the working directory
WORKDIR /app

# Copy the package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the codebase
COPY . .

# Expose the port for the React app
EXPOSE 3001

# Start the React development server
CMD ["npm", "start"]
