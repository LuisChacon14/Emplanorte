# 🚀 EMPLANORTE - Inventory Management System

<p align="center">






\

</p>

<p align="center">
A modern inventory management platform developed with <strong>Spring Boot</strong>, <strong>PostgreSQL</strong> and <strong>Docker</strong>, applying Software Engineering best practices.
</p>

---

# 📖 Overview

EMPLANORTE is an inventory management platform designed to optimize the administration of products, customers, suppliers, quotations and sales within an organization.

The project was developed following software engineering principles, using an agile development process, UML modeling, software documentation, relational database design and containerized deployment with Docker.

Besides implementing the business logic, the project includes complete technical documentation such as software requirements, UML diagrams, risk analysis and testing documentation.

---

# ✨ Main Features

* Product management
* Inventory control
* Customer management
* Supplier management
* Sales registration
* Quotations
* Expense management
* Dashboard
* PostgreSQL persistence
* Dockerized deployment
* Software documentation
* UML diagrams

---

# 🛠 Tech Stack

## Backend

* Java 21
* Spring Boot
* Spring MVC
* Maven

## Database

* PostgreSQL

## DevOps

* Docker
* Docker Compose

## Version Control

* Git
* GitHub

## Software Engineering

* UML
* Scrum
* Software Requirements Specification
* Risk Analysis
* Test Plan
* Technical Documentation

---

# 📂 Project Structure

```text
EMPLANORTE
│
├── backend
│   ├── src
│   ├── pom.xml
│   └── Dockerfile
│
├── frontend
│
├── docs
│   ├── Requirements
│   ├── UML
│   ├── Risk Management
│   ├── Test Plan
│   └── User Documentation
│
├── database
│
└── README.md
```

---

# 🏗 System Architecture

The application follows a layered architecture based on Spring Boot.

```text
Client
   │
   ▼
Controllers
   │
   ▼
Services
   │
   ▼
Repositories
   │
   ▼
PostgreSQL Database
```

This architecture improves maintainability, scalability and code organization.

---

# 💾 Database

Database Engine

* PostgreSQL

The database stores all information related to:

* Products
* Categories
* Customers
* Suppliers
* Sales
* Quotations
* Expenses
* Inventory

The relational model was designed following normalization principles to ensure data integrity and consistency.

---

# ⚙ Requirements

Software

* Java JDK 21
* Maven
* PostgreSQL
* Docker (optional)

Recommended IDE

* IntelliJ IDEA
* Visual Studio Code
* Eclipse

Operating Systems

* Linux
* Windows

---

# 🚀 Installation

Clone the repository

```bash
git clone https://github.com/MAnza25/Emplanorte.git
```

Move into the project

```bash
cd Emplanorte
```

Build the project

```bash
mvn clean install
```

Run the application

```bash
mvn spring-boot:run
```

---

# 🐳 Running with Docker

Build the containers

```bash
docker compose up --build
```

Run the project

```bash
docker compose up
```

Stop the containers

```bash
docker compose down
```

---

# ⚙ Configuration

Configure your PostgreSQL connection in the application configuration file.

Example:

```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/emplanorte
spring.datasource.username=YOUR_USERNAME
spring.datasource.password=YOUR_PASSWORD
```

---

# 📑 Documentation

The repository includes software engineering documentation such as:

* Software Requirements Specification
* UML Diagrams
* Use Cases
* Risk Management
* Test Plan
* Technical Documentation

---

# 📸 Screenshots

Add screenshots of:

* Login
* Dashboard
* Inventory Module
* Customer Module
* Sales Module
* Reports

Example:

```text
docs/images/login.png
docs/images/dashboard.png
```

---

# 🎯 Future Improvements

* Authentication with JWT
* Role-based access control
* REST API documentation with Swagger
* Automated testing
* CI/CD pipeline
* Cloud deployment
* Email notifications
* Inventory analytics

---

# 📚 Learning Outcomes

During the development of this project, the following technologies and concepts were applied:

* Java
* Spring Boot
* PostgreSQL
* Docker
* Git
* GitHub
* Maven
* Object-Oriented Programming
* Layered Architecture
* Software Engineering
* Scrum
* UML Modeling
* Database Design

---

# 👨‍💻 Author

**Braqner Duván Alvarado Delgado**
**Salomé Amaya Rios**
**Luis Sebatian Chagon Gelvez** 

Systems Engineering Students

Universidad de Pamplona

---

# ⭐ Support

If you found this project useful, consider giving it a ⭐ on GitHub.

---

# 📄 License

This project is licensed under the MIT License.
