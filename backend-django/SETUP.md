# Backend Setup Guide

## Prerequisites
- Python 3.8 or higher
- PostgreSQL
- Git

## Initial Setup

### 1. Clone the Repository
```bash
git clone <your-repository-url>
cd backend-django
```

### 2. Create and Activate Virtual Environment
```bash
# Create virtual environment
python -m venv venv

# Activate virtual environment
# On Windows:
.\venv\Scripts\activate
# On macOS/Linux:
source venv/bin/activate
```

### 3. Install Dependencies
```bash
pip install -r requirements.txt
```

### 4. Database Setup
1. Create a PostgreSQL database
2. Update database settings in `alumni_project/settings.py`
3. Run migrations:
```bash
python manage.py makemigrations
python manage.py migrate
```

### 5. Create Superuser
```bash
python manage.py createsuperuser
```

### 6. Run Development Server
```bash
python manage.py runserver
```

## API Endpoints

### Authentication
- `POST /api/register/` - Register new user
- `POST /api/login/` - Login user
- `POST /api/logout/` - Logout user
- `POST /api/token/refresh/` - Refresh JWT token

### Alumni
- `GET /api/alumni/` - List all alumni
- `POST /api/alumni/` - Create new alumni
- `GET /api/alumni/<id>/` - Get specific alumni
- `PUT /api/alumni/<id>/` - Update alumni
- `DELETE /api/alumni/<id>/` - Delete alumni

### Events
- `GET /api/events/` - List all events
- `POST /api/events/` - Create new event
- `GET /api/events/<id>/` - Get specific event
- `PUT /api/events/<id>/` - Update event
- `DELETE /api/events/<id>/` - Delete event

## Development Guidelines

### Adding New Dependencies
When adding new Python packages:
```bash
pip install <package-name>
pip freeze > requirements.txt
```

### Database Migrations
After model changes:
```bash
python manage.py makemigrations
python manage.py migrate
```

### Environment Variables
Create a `.env` file in the project root:
```env
DEBUG=True
SECRET_KEY=your_secret_key
DATABASE_URL=postgresql://user:password@localhost:5432/dbname
```

## Troubleshooting

### Common Issues
1. Database connection errors:
   - Check PostgreSQL service is running
   - Verify database credentials

2. Migration errors:
   - Delete migrations folder (except `__init__.py`)
   - Delete database
   - Run migrations again

3. Package conflicts:
   - Delete `venv` folder
   - Create new virtual environment
   - Reinstall requirements

### Getting Help
Contact project maintainers at:
- Email: hamuhumuza@gmail.com
- GitHub Issues: (https://github.com/HandharJunino/backend-django/issues)
