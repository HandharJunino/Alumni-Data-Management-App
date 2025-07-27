# 🎓 Alumni Data Management App

Design and Development of a Web Application for Alumni Data Management.

## 📋 Project Overview

This is a full-stack web application designed to manage alumni data efficiently. The system allows administrators to track alumni information, manage events, and maintain contact records.

**Tech Stack:**
- **Backend**: Django REST Framework with Python
- **Frontend**: Flutter Web Application
- **Database**: SQLite (Development) / PostgreSQL (Production)
- **Authentication**: JWT Token-based Authentication

## 🏗️ Project Structure

```
Alumni Data Management App/
├── backend-django/              # Django REST API Backend
│   ├── alumni_app/             # Main Django application
│   │   ├── models.py           # Database models
│   │   ├── views.py            # API views and logic
│   │   ├── serializers.py      # Data serialization
│   │   └── urls.py             # API endpoints
│   ├── alumni_project/         # Django project settings
│   ├── requirements.txt        # Python dependencies
│   ├── manage.py              # Django management script
│   └── .gitignore             # Backend-specific ignores
├── frontend-flutter/           # Flutter Web Frontend
│   ├── lib/                   # Dart source code
│   │   ├── main.dart          # App entry point
│   │   ├── models/            # Data models
│   │   ├── pages/             # UI screens
│   │   └── functions/         # Business logic
│   ├── web/                   # Web-specific configuration
│   ├── pubspec.yaml           # Flutter dependencies
│   └── test/                  # Flutter tests
├── .gitignore                 # Project-wide ignores
└── README.md                  # This file
```

## ✨ Features

### Alumni Management
- ✅ Create, read, update, and delete alumni records
- ✅ Track contact information (name, email, phone, country)
- ✅ Record academic details (course, graduation year)
- ✅ Store professional information (company, area of expertise)
- ✅ Set availability and contact preferences

### Event Management
- ✅ Create and manage alumni events
- ✅ Track event attendance
- ✅ Alumni-event relationship management

### Contact Tracking
- ✅ Record previous contacts with alumni
- ✅ Track contact methods and descriptions
- ✅ Associate contacts with specific users

### Authentication & Security
- ✅ JWT-based authentication
- ✅ User registration and login
- ✅ Password reset functionality
- ✅ Secure API endpoints

### Advanced Features
- ✅ Alumni filtering and search capabilities
- ✅ Recommended alumni for events
- ✅ RESTful API with comprehensive endpoints

## 🚀 Getting Started

### Prerequisites

Make sure you have the following installed:
- **Python 3.8+**
- **Flutter SDK 3.6.1+**
- **Git**
- **PostgreSQL** (for production) or **SQLite** (for development)

### Backend Setup (Django)

1. **Navigate to backend directory**
   ```bash
   cd backend-django
   ```

2. **Create and activate virtual environment**
   ```bash
   # Windows
   python -m venv .venv
   .venv\Scripts\activate

   # macOS/Linux
   python3 -m venv .venv
   source .venv/bin/activate
   ```

3. **Install Python dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Set up environment variables**
   ```bash
   # Create .env file with your configuration
   # Example:
   DEBUG=True
   SECRET_KEY=your-secret-key-here
   DATABASE_URL=sqlite:///db.sqlite3
   ```

5. **Run database migrations**
   ```bash
   python manage.py makemigrations
   python manage.py migrate
   ```

6. **Create a superuser (optional)**
   ```bash
   python manage.py createsuperuser
   ```

7. **Start the Django development server**
   ```bash
   python manage.py runserver
   ```

   The API will be available at `http://127.0.0.1:8000/`

### Frontend Setup (Flutter)

1. **Navigate to frontend directory**
   ```bash
   cd frontend-flutter
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the Flutter web application**
   ```bash
   flutter run -d chrome
   ```

   The web app will be available at `http://localhost:3000/` (or the port shown in terminal)

## 🔧 API Endpoints

### Authentication
- `POST /api/register/` - User registration
- `POST /api/login/` - User login
- `POST /api/logout/` - User logout
- `POST /api/forgot-password/` - Password reset

### Alumni Management
- `GET /api/alumni/` - List all alumni (with filtering)
- `POST /api/alumni/` - Create new alumni
- `GET /api/alumni/{id}/` - Get specific alumni
- `PUT /api/alumni/{id}/` - Update alumni
- `DELETE /api/alumni/{id}/` - Delete alumni

### Events
- `GET /api/events/` - List all events
- `POST /api/events/` - Create new event
- `GET /api/events/{id}/` - Get specific event
- `PUT /api/events/{id}/` - Update event
- `DELETE /api/events/{id}/` - Delete event

### Contact History
- `GET /api/contacts/` - List contact history
- `POST /api/contacts/` - Record new contact
- `GET /api/contacts/?alumni={id}` - Get contacts for specific alumni

## 🗃️ Database Models

### Alumni Model
- Personal Information: name, email, phone
- Academic: prior_course, year_of_graduation
- Professional: company, area_of_expertise
- Contact Preferences: availability, contact_times, country

### Event Model
- Basic Information: name, date, time, description

### AlumniEvent Model
- Relationship between Alumni and Events
- Attendance tracking

### PreviousContact Model
- Contact history tracking
- Associated with User and Alumni

## 🧪 Testing

### Backend Testing
```bash
cd backend-django
python manage.py test
```

### Frontend Testing
```bash
cd frontend-flutter
flutter test
```

## 🔒 Security Features

- JWT token-based authentication
- Password hashing
- CORS protection
- Input validation and sanitization
- Protected API endpoints

## 📱 Frontend Features

- Responsive design for web and mobile
- Material Design UI components
- State management with Provider
- HTTP client for API communication
- Secure storage for authentication tokens

## 🛠️ Development Tools

- **Backend**: Django Admin Panel at `/admin/`
- **API Documentation**: Available at `/api/docs/` (if configured)
- **Testing**: Comprehensive test suites for both backend and frontend
- **Linting**: Code quality enforcement

## 📦 Dependencies

### Backend (Django)
- Django 5.1.7
- Django REST Framework
- django-filter
- django-cors-headers
- djangorestframework-simplejwt
- psycopg2 (PostgreSQL)

### Frontend (Flutter)
- http (API communication)
- provider (State management)
- flutter_secure_storage (Secure token storage)
- shared_preferences (Local storage)
- font_awesome_flutter (Icons)

## 🚀 Deployment

### Backend Deployment
1. Set up PostgreSQL database
2. Configure environment variables
3. Run migrations: `python manage.py migrate`
4. Collect static files: `python manage.py collectstatic`
5. Deploy using your preferred platform (Heroku, AWS, etc.)

### Frontend Deployment
1. Build for web: `flutter build web`
2. Deploy the `build/web` directory to your web server

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes and commit: `git commit -m 'Add feature'`
4. Push to the branch: `git push origin feature-name`
5. Submit a pull request

## 📝 License

This project is developed for educational purposes as part of a university project.

## 👨‍💻 Author

**Handhwarah Muhumuza**  
Year 3 Student - University of Portsmouth
GitHub: [@HandharJunino](https://github.com/HandharJunino)

---

## 📞 Support

For support or questions about this project, please:
1. Check the existing issues on GitHub
2. Create a new issue if needed
3. Contact the development team

---

**Note**: This is an academic project developed for my Final Year Project.
