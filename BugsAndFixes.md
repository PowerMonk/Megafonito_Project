# Bugs and Fixes - Megafonito App

This document tracks significant bugs discovered during development and their solutions.

---

# Frontend

## Navigation System Overhaul

### Issue: Bottom Navigation Bar Implementation

**Problem:** Converting from FAB menu to bottom navigation bar required restructuring screen rendering.

**Solution:**

- Implemented BottomNavigationBar with fixed navigation items
- Added IndexedStack for efficient tab switching
- Created a current index tracker to manage active tab

### Issue: AppBar Redundancy

**Problem:** Each screen had its own AppBar, causing duplicate headers when integrated with tab navigation.

**Solution:**

- Removed individual AppBars from tab content screens
- Maintained single AppBar in main screen with dynamic title
- Preserved AppBars only in screens accessed via Navigator.push()
- Converted tab content screens to return Container instead of Scaffold

### Issue: Navigation Back Arrows Inconsistency

**Problem:** Some screens had white back arrows while others had black ones.

**Solution:**

- Added global AppBar theme in main.dart:

```dart
theme: ThemeData(
  appBarTheme: AppBarTheme(
    iconTheme: IconThemeData(color: Colors.white),
    actionsIconTheme: IconThemeData(color: Colors.white),
  ),
),
```

## State Management Issues

### Issue: Announcements Not Displaying After Creation

**Problem:** New announcements weren't appearing after creation because the announcements screen was built once during initialization and stored in an IndexedStack.

**Solution:**

- Removed static initialization of screens in initState()
- Dynamically built the announcements content in the build method:

```dart
body: _currentIndex == 0
    ? _buildAnunciosContent()  // Dynamically build when selected
    : IndexedStack(
        index: _currentIndex - 1,
        children: [
          // Other screens...
        ],
      ),
```

---

# Backend

---

# Implementations

## Frontend

### Enhanced Filtering System

- Created dedicated NoticesFilter component for better separation of concerns
- Implemented horizontal scrollable category chips for better UX
- Added dropdown menu for sorting options (newest, oldest, with attachments)
- Fixed layout to properly align filter button with category list
- Ensured proper spacing and visual hierarchy in filter UI

### File Attachment Feature

- Added file attachment capability to announcement creation
- Implemented "Agregar archivo" button with paperclip icon
- Added visual feedback when files are attached
- Updated announcement model to track file attachment status
- Integrated file attachment status with filtering system

### Category-based Filtering

- Standardized categories across creation and filtering interfaces
- Replaced importance-based coloring with category-based filtering
- Updated filter logic to properly handle category selection
- Implemented visual indicators for active filters
- Ensured consistent category options between screens

---

## Backend

_Backend implementations pending_
