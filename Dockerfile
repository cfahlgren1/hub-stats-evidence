# Use an official Node.js runtime as the base image
FROM node:18

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json (if available)
COPY package*.json ./

# Install project dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Build the Evidence project
RUN npm run build

# Expose the port that the app runs on (adjust if needed)
EXPOSE 3000

# Command to run the application
CMD ["npm", "run", "preview"]