@echo off
REM StudyMaster AI - Windows Setup Script
REM Run this script to set up the complete project

echo ============================================
echo StudyMaster AI - Automated Setup (Windows)
echo ============================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python 3.8+ from https://www.python.org/
    pause
    exit /b 1
)

REM Check if Node.js is installed
node --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Node.js is not installed or not in PATH
    echo Please install Node.js from https://nodejs.org/
    pause
    exit /b 1
)

echo [1/6] Creating backend folder structure...
mkdir backend\modules\parsers 2>nul
mkdir backend\modules\ai 2>nul
mkdir backend\modules\flashcards 2>nul
mkdir backend\modules\scheduler 2>nul
mkdir backend\modules\analytics 2>nul
mkdir backend\modules\exporters 2>nul
mkdir backend\database 2>nul
mkdir backend\api 2>nul
mkdir backend\tests 2>nul
echo    Done!

echo [2/6] Creating backend files...

REM Create requirements.txt
(
echo fastapi==0.104.1
echo uvicorn==0.24.0
echo pydantic==2.5.0
echo sqlalchemy==2.0.23
echo PyPDF2==3.0.1
echo python-docx==1.1.0
echo python-pptx==0.6.23
echo youtube-transcript-api==0.6.1
echo openai==1.3.0
echo python-multipart==0.0.6
echo aiofiles==23.2.1
echo pytest==7.4.3
) > backend\requirements.txt

REM Create __init__.py files
type nul > backend\modules\__init__.py
type nul > backend\modules\parsers\__init__.py
type nul > backend\modules\ai\__init__.py
type nul > backend\modules\flashcards\__init__.py
type nul > backend\modules\scheduler\__init__.py
type nul > backend\modules\analytics\__init__.py
type nul > backend\modules\exporters\__init__.py
type nul > backend\database\__init__.py
type nul > backend\api\__init__.py
type nul > backend\tests\__init__.py

REM Create config.py
(
echo import os
echo.
echo class Config:
echo     OPENAI_API_KEY = os.getenv^("OPENAI_API_KEY", ""^)
echo     DATABASE_URL = os.getenv^("DATABASE_URL", "sqlite:///study_tool.db"^)
echo     MAX_UPLOAD_SIZE = 50 * 1024 * 1024
echo     AI_MODEL = "gpt-4o-mini"
) > backend\config.py

REM Create .env.example
(
echo OPENAI_API_KEY=your_openai_api_key_here
echo DATABASE_URL=sqlite:///study_tool.db
) > backend\.env.example

REM Create PDF Parser
(
echo import PyPDF2
echo from typing import Dict, List
echo import re
echo.
echo class PDFParser:
echo     def __init__^(self^):
echo         self.supported_formats = ['.pdf']
echo.
echo     def extract_text^(self, file_path: str^) -^> Dict:
echo         try:
echo             with open^(file_path, 'rb'^) as file:
echo                 reader = PyPDF2.PdfReader^(file^)
echo                 full_text = ""
echo                 for page in reader.pages:
echo                     full_text += page.extract_text^(^) + "\n"
echo                 return {'success': True, 'full_text': full_text}
echo         except Exception as e:
echo             return {'success': False, 'error': str^(e^)}
) > backend\modules\parsers\pdf_parser.py

REM Create DOCX Parser
(
echo from docx import Document
echo from typing import Dict
echo.
echo class DOCXParser:
echo     def __init__^(self^):
echo         self.supported_formats = ['.docx', '.doc']
echo.
echo     def extract_text^(self, file_path: str^) -^> Dict:
echo         try:
echo             doc = Document^(file_path^)
echo             full_text = "\n".join^([para.text for para in doc.paragraphs]^)
echo             return {'success': True, 'full_text': full_text}
echo         except Exception as e:
echo             return {'success': False, 'error': str^(e^)}
) > backend\modules\parsers\docx_parser.py

REM Create PPTX Parser
(
echo from pptx import Presentation
echo from typing import Dict
echo.
echo class PPTXParser:
echo     def __init__^(self^):
echo         self.supported_formats = ['.pptx', '.ppt']
echo.
echo     def extract_text^(self, file_path: str^) -^> Dict:
echo         try:
echo             prs = Presentation^(file_path^)
echo             full_text = ""
echo             for slide in prs.slides:
echo                 for shape in slide.shapes:
echo                     if hasattr^(shape, "text"^):
echo                         full_text += shape.text + "\n"
echo             return {'success': True, 'full_text': full_text}
echo         except Exception as e:
echo             return {'success': False, 'error': str^(e^)}
) > backend\modules\parsers\pptx_parser.py

REM Create YouTube Parser
(
echo from youtube_transcript_api import YouTubeTranscriptApi
echo import re
echo from typing import Dict
echo.
echo class YouTubeParser:
echo     def extract_transcript^(self, url: str^) -^> Dict:
echo         try:
echo             video_id = self._extract_video_id^(url^)
echo             if not video_id:
echo                 return {'success': False, 'error': 'Invalid URL'}
echo             transcript = YouTubeTranscriptApi.get_transcript^(video_id^)
echo             full_text = " ".join^([item['text'] for item in transcript]^)
echo             return {'success': True, 'full_text': full_text}
echo         except Exception as e:
echo             return {'success': False, 'error': str^(e^)}
echo.
echo     def _extract_video_id^(self, url: str^):
echo         match = re.search^(r'(?:v=^|youtu.be/^)^([^&\n?#]+^)', url^)
echo         return match.group^(1^) if match else None
) > backend\modules\parsers\youtube_parser.py

REM Create main API file
(
echo from fastapi import FastAPI, UploadFile, File
echo from fastapi.middleware.cors import CORSMiddleware
echo import sys
echo import os
echo sys.path.insert^(0, os.path.dirname^(os.path.abspath^(__file__^)^)^)
echo.
echo app = FastAPI^(title="StudyMaster AI"^)
echo.
echo app.add_middleware^(
echo     CORSMiddleware,
echo     allow_origins=["http://localhost:3000"],
echo     allow_credentials=True,
echo     allow_methods=["*"],
echo     allow_headers=["*"]
echo ^)
echo.
echo @app.get^("/")
echo async def root^(^):
echo     return {"message": "StudyMaster AI API", "version": "1.0.0"}
echo.
echo @app.get^("/health"^)
echo async def health^(^):
echo     return {"status": "healthy"}
) > backend\api\main.py

echo    Done!

echo [3/6] Setting up Python virtual environment...
cd backend
python -m venv venv
echo    Done!

echo [4/6] Installing Python dependencies...
call venv\Scripts\activate.bat
pip install -q -r requirements.txt
if errorlevel 1 (
    echo    WARNING: Some packages may have failed to install
) else (
    echo    Done!
)
cd ..

echo [5/6] Creating React frontend...
call npx create-react-app frontend
cd frontend

echo [6/6] Installing frontend dependencies...
call npm install lucide-react
call npm install -D tailwindcss postcss autoprefixer
call npx tailwindcss init -p

REM Create tailwind.config.js
(
echo module.exports = {
echo   content: ["./src/**/*.{js,jsx,ts,tsx}"],
echo   theme: { extend: {} },
echo   plugins: [],
echo }
) > tailwind.config.js

REM Create src\index.css
(
echo @tailwind base;
echo @tailwind components;
echo @tailwind utilities;
) > src\index.css

REM Create src\index.js
(
echo import React from 'react';
echo import ReactDOM from 'react-dom/client';
echo import './index.css';
echo import App from './App';
echo.
echo const root = ReactDOM.createRoot^(document.getElementById^('root'^)^);
echo root.render^(
echo   ^<React.StrictMode^>
echo     ^<App /^>
echo   ^</React.StrictMode^>
echo ^);
) > src\index.js

REM Delete default files
del src\App.js 2>nul
del src\App.css 2>nul
del src\App.test.js 2>nul
del src\logo.svg 2>nul

REM Create simplified App.jsx
(
echo import React, { useState } from 'react';
echo import { Brain, Upload, BarChart3 } from 'lucide-react';
echo.
echo const StudyToolApp = ^(^) =^> {
echo   const [activeTab, setActiveTab] = useState^('upload'^);
echo.
echo   return ^(
echo     ^<div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100"^>
echo       ^<header className="bg-white shadow-sm"^>
echo         ^<div className="max-w-7xl mx-auto px-4 py-4"^>
echo           ^<div className="flex items-center space-x-3"^>
echo             ^<Brain className="w-8 h-8 text-indigo-600" /^>
echo             ^<h1 className="text-2xl font-bold"^>StudyMaster AI^</h1^>
echo           ^</div^>
echo         ^</div^>
echo       ^</header^>
echo       ^<main className="max-w-7xl mx-auto px-4 py-8"^>
echo         ^<div className="bg-white rounded-xl shadow-lg p-8"^>
echo           ^<h2 className="text-3xl font-bold mb-4"^>Welcome! 🎓^</h2^>
echo           ^<p^>Upload study materials to generate flashcards.^</p^>
echo         ^</div^>
echo       ^</main^>
echo     ^</div^>
echo   ^);
echo };
echo.
echo export default StudyToolApp;
) > src\App.jsx

cd ..

REM Update root README
(
echo # StudyMaster AI
echo.
echo AI-powered study tool
echo.
echo ## Quick Start
echo.
echo ### Backend
echo ```
echo cd backend
echo venv\Scripts\activate
echo set OPENAI_API_KEY=your-key
echo uvicorn api.main:app --reload
echo ```
echo.
echo ### Frontend
echo ```
echo cd frontend
echo npm start
echo ```
echo.
echo Access: http://localhost:3000
) > README.md

echo.
echo ============================================
echo          Setup Complete!
echo ============================================
echo.
echo Next steps:
echo.
echo 1. Set your OpenAI API key:
echo    set OPENAI_API_KEY=your-key-here
echo.
echo 2. Start backend (Terminal 1):
echo    cd backend
echo    venv\Scripts\activate
echo    uvicorn api.main:app --reload
echo.
echo 3. Start frontend (Terminal 2):
echo    cd frontend
echo    npm start
echo.
echo Your app will be at: http://localhost:3000
echo API docs at: http://localhost:8000/docs
echo.
pause
