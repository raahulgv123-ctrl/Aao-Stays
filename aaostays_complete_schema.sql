-- ============================================
-- AaoStays - Property Booking System
-- Complete MySQL Database Schema
-- Version: 1.0
-- Created: 2025-11-09
-- ============================================

DROP DATABASE IF EXISTS aaostays;
CREATE DATABASE aaostays CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE aaostays;

-- ============================================
-- USER MANAGEMENT TABLES
-- ============================================

-- Main User Table (Parent for all user types)
CREATE TABLE USER (
    user_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20),
    user_type ENUM('GUEST', 'HOST', 'ADMIN', 'EMPLOYEE') NOT NULL,
    profile_picture_url VARCHAR(512),
    date_of_birth DATE,
    address TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    is_email_verified BOOLEAN DEFAULT FALSE,
    is_phone_verified BOOLEAN DEFAULT FALSE,
    last_login DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_user_type (user_type),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB COMMENT='Main user table for all user types';

-- Guest User Profile
CREATE TABLE GUEST (
    guest_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    preferred_currency VARCHAR(10) DEFAULT 'INR',
    preferred_language VARCHAR(10) DEFAULT 'en',
    preferences TEXT COMMENT 'JSON string of user preferences',
    total_bookings INT DEFAULT 0,
    total_spent DECIMAL(15, 2) DEFAULT 0.00,
    loyalty_points INT DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES USER(user_id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_loyalty_points (loyalty_points)
) ENGINE=InnoDB COMMENT='Guest user profiles for booking properties';

-- Host User Profile
CREATE TABLE HOST (
    host_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    bio TEXT,
    profile_picture VARCHAR(512),
    languages_spoken VARCHAR(255),
    is_superhost BOOLEAN DEFAULT FALSE,
    host_since DATE,
    is_verified BOOLEAN DEFAULT FALSE,
    verification_status ENUM('PENDING', 'VERIFIED', 'REJECTED') DEFAULT 'PENDING',
    government_id_type VARCHAR(50),
    government_id_number VARCHAR(100),
    id_verified BOOLEAN DEFAULT FALSE,
    total_properties INT DEFAULT 0,
    active_properties INT DEFAULT 0,
    total_bookings INT DEFAULT 0,
    total_earnings DECIMAL(15, 2) DEFAULT 0.00,
    earnings_per_month DECIMAL(15, 2) DEFAULT 0.00,
    average_rating DECIMAL(3, 2) DEFAULT 0.00,
    response_rate DECIMAL(5, 2) DEFAULT 0.00 COMMENT 'Percentage',
    response_time INT DEFAULT 0 COMMENT 'Average response time in minutes',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES USER(user_id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_is_superhost (is_superhost),
    INDEX idx_is_verified (is_verified),
    INDEX idx_average_rating (average_rating)
) ENGINE=InnoDB COMMENT='Host user profiles for listing properties';

-- Admin User Profile
CREATE TABLE ADMIN (
    admin_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    admin_level VARCHAR(50) DEFAULT 'STANDARD',
    permissions TEXT COMMENT 'JSON string of permissions',
    department VARCHAR(100),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES USER(user_id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_admin_level (admin_level)
) ENGINE=InnoDB COMMENT='Admin user profiles for system management';

-- Employee User Profile
CREATE TABLE EMPLOYEE (
    employee_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    employee_role VARCHAR(100),
    employee_code VARCHAR(50) NOT NULL UNIQUE,
    hire_date DATE,
    salary DECIMAL(12, 2),
    department VARCHAR(100),
    manager_id BIGINT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES USER(user_id) ON DELETE CASCADE,
    FOREIGN KEY (manager_id) REFERENCES EMPLOYEE(employee_id) ON DELETE SET NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_employee_code (employee_code),
    INDEX idx_is_active (is_active),
    INDEX idx_manager_id (manager_id)
) ENGINE=InnoDB COMMENT='Employee user profiles for property management';

-- ============================================
-- CATEGORY AND AMENITY TABLES
-- ============================================

-- Property Categories
CREATE TABLE CATEGORY (
    category_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    category_description TEXT,
    category_icon VARCHAR(255),
    category_image VARCHAR(512),
    display_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_category_name (category_name),
    INDEX idx_is_active (is_active),
    INDEX idx_display_order (display_order)
) ENGINE=InnoDB COMMENT='Property categories (e.g., Villa, Apartment, Hotel)';

-- Property Amenities
CREATE TABLE AMENITY (
    amenity_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    amenity_name VARCHAR(100) NOT NULL UNIQUE,
    amenity_description TEXT,
    amenity_category VARCHAR(100) COMMENT 'e.g., Basic, Entertainment, Safety',
    amenity_icon VARCHAR(255),
    display_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_amenity_name (amenity_name),
    INDEX idx_amenity_category (amenity_category),
    INDEX idx_is_active (is_active),
    INDEX idx_display_order (display_order)
) ENGINE=InnoDB COMMENT='Property amenities (e.g., WiFi, Pool, Parking)';

-- ============================================
-- PROPERTY TABLES
-- ============================================

-- Main Property Table
CREATE TABLE PROPERTY (
    property_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    host_id BIGINT NOT NULL,
    employee_id BIGINT,
    admin_id BIGINT,
    property_name VARCHAR(255) NOT NULL,
    property_type VARCHAR(100) COMMENT 'e.g., Entire Place, Private Room, Shared Room',
    category_type VARCHAR(100),
    description TEXT,
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100) DEFAULT 'India',
    postal_code VARCHAR(20),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    location_url VARCHAR(512),
    map_embed_url VARCHAR(512),
    base_guests INT DEFAULT 1,
    max_guests INT DEFAULT 1,
    extra_guest_allowed BOOLEAN DEFAULT FALSE,
    extra_guest_fee DECIMAL(10, 2) DEFAULT 0.00,
    bedrooms INT DEFAULT 0,
    beds INT DEFAULT 0,
    bathrooms INT DEFAULT 0,
    restrooms INT DEFAULT 0,
    kitchen_type VARCHAR(50) COMMENT 'e.g., Full Kitchen, Kitchenette, None',
    pets_allowed BOOLEAN DEFAULT FALSE,
    smoking_allowed BOOLEAN DEFAULT FALSE,
    events_allowed BOOLEAN DEFAULT FALSE,
    price_per_night DECIMAL(10, 2) NOT NULL,
    cleaning_fee DECIMAL(10, 2) DEFAULT 0.00,
    service_fee DECIMAL(10, 2) DEFAULT 0.00,
    weekend_price DECIMAL(10, 2),
    weekly_discount_percent DECIMAL(5, 2) DEFAULT 0.00,
    monthly_discount_percent DECIMAL(5, 2) DEFAULT 0.00,
    currency VARCHAR(10) DEFAULT 'INR',
    minimum_stay INT DEFAULT 1 COMMENT 'Minimum nights required',
    maximum_stay INT DEFAULT 365 COMMENT 'Maximum nights allowed',
    check_in_time TIME DEFAULT '14:00:00',
    check_out_time TIME DEFAULT '11:00:00',
    cancellation_policy VARCHAR(50) DEFAULT 'MODERATE' COMMENT 'FLEXIBLE, MODERATE, STRICT',
    instant_booking BOOLEAN DEFAULT FALSE,
    property_status ENUM('DRAFT', 'PENDING_APPROVAL', 'ACTIVE', 'INACTIVE', 'SUSPENDED') DEFAULT 'DRAFT',
    approval_status ENUM('PENDING', 'APPROVED', 'REJECTED') DEFAULT 'PENDING',
    is_active BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE,
    rating_average DECIMAL(3, 2) DEFAULT 0.00,
    total_reviews INT DEFAULT 0,
    total_bookings INT DEFAULT 0,
    views_count INT DEFAULT 0,
    wishlist_count INT DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    published_at DATETIME,
    FOREIGN KEY (host_id) REFERENCES HOST(host_id) ON DELETE CASCADE,
    FOREIGN KEY (employee_id) REFERENCES EMPLOYEE(employee_id) ON DELETE SET NULL,
    FOREIGN KEY (admin_id) REFERENCES ADMIN(admin_id) ON DELETE SET NULL,
    INDEX idx_host_id (host_id),
    INDEX idx_city (city),
    INDEX idx_state (state),
    INDEX idx_country (country),
    INDEX idx_property_status (property_status),
    INDEX idx_is_active (is_active),
    INDEX idx_is_featured (is_featured),
    INDEX idx_price (price_per_night),
    INDEX idx_rating (rating_average),
    INDEX idx_location (latitude, longitude),
    INDEX idx_instant_booking (instant_booking)
) ENGINE=InnoDB COMMENT='Main property listings table';

-- Property Images
CREATE TABLE PROPERTY_IMAGE (
    image_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    property_id BIGINT NOT NULL,
    image_url VARCHAR(512) NOT NULL,
    image_caption VARCHAR(255),
    display_order INT DEFAULT 0,
    is_primary BOOLEAN DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (property_id) REFERENCES PROPERTY(property_id) ON DELETE CASCADE,
    INDEX idx_property_id (property_id),
    INDEX idx_display_order (display_order),
    INDEX idx_is_primary (is_primary)
) ENGINE=InnoDB COMMENT='Property images';

-- Property Contact Details
CREATE TABLE CONTACT_DETAILS (
    contact_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    property_id BIGINT NOT NULL UNIQUE,
    contact_name VARCHAR(255),
    email VARCHAR(255),
    primary_mobile VARCHAR(20),
    alternate_mobile VARCHAR(20),
    preferred_contact_method VARCHAR(50) DEFAULT 'PHONE',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (property_id) REFERENCES PROPERTY(property_id) ON DELETE CASCADE,
    INDEX idx_property_id (property_id)
) ENGINE=InnoDB COMMENT='Property contact information';

-- Property-Category Junction Table (Many-to-Many)
CREATE TABLE PROPERTY_CATEGORY (
    property_category_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    property_id BIGINT NOT NULL,
    category_id BIGINT NOT NULL,
    assigned_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (property_id) REFERENCES PROPERTY(property_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES CATEGORY(category_id) ON DELETE CASCADE,
    UNIQUE KEY unique_property_category (property_id, category_id),
    INDEX idx_property_id (property_id),
    INDEX idx_category_id (category_id)
) ENGINE=InnoDB COMMENT='Links properties to categories';

-- Property-Amenity Junction Table (Many-to-Many)
CREATE TABLE PROPERTY_AMENITY (
    property_amenity_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    property_id BIGINT NOT NULL,
    amenity_id BIGINT NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    notes VARCHAR(255),
    assigned_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (property_id) REFERENCES PROPERTY(property_id) ON DELETE CASCADE,
    FOREIGN KEY (amenity_id) REFERENCES AMENITY(amenity_id) ON DELETE CASCADE,
    UNIQUE KEY unique_property_amenity (property_id, amenity_id),
    INDEX idx_property_id (property_id),
    INDEX idx_amenity_id (amenity_id)
) ENGINE=InnoDB COMMENT='Links properties to amenities';

-- Property House Rules
CREATE TABLE PROPERTY_RULE (
    rule_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    property_id BIGINT NOT NULL,
    rule_text TEXT NOT NULL,
    rule_category VARCHAR(50) COMMENT 'e.g., Check-in/out, Safety, Behavior',
    display_order INT DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (property_id) REFERENCES PROPERTY(property_id) ON DELETE CASCADE,
    INDEX idx_property_id (property_id)
) ENGINE=InnoDB COMMENT='Property house rules and policies';

-- Property Discounts
CREATE TABLE DISCOUNT (
    discount_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    property_id BIGINT NOT NULL UNIQUE,
    discount_name VARCHAR(255),
    discount_type VARCHAR(50) COMMENT 'e.g., EARLY_BIRD, WEEKLY, MONTHLY, SEASONAL',
    discount_percentage DECIMAL(5, 2),
    min_nights_required INT DEFAULT 1,
    valid_from DATE,
    valid_until DATE,
    days_before_checkin INT COMMENT 'For early bird discounts',
    max_discount_amount DECIMAL(10, 2),
    is_active BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (property_id) REFERENCES PROPERTY(property_id) ON DELETE CASCADE,
    INDEX idx_property_id (property_id),
    INDEX idx_is_active (is_active),
    INDEX idx_valid_dates (valid_from, valid_until)
) ENGINE=InnoDB COMMENT='Property-specific discounts';

-- ============================================
-- ROOM TABLES
-- ============================================

-- Rooms within Properties
CREATE TABLE ROOM (
    room_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    property_id BIGINT NOT NULL,
    created_by_employee_id BIGINT,
    updated_by_employee_id BIGINT,
    room_number VARCHAR(50),
    room_type VARCHAR(100) COMMENT 'e.g., Deluxe, Suite, Standard',
    room_name VARCHAR(255),
    room_description TEXT,
    base_guests INT DEFAULT 1,
    max_guests INT DEFAULT 1,
    extra_guest_allowed BOOLEAN DEFAULT FALSE,
    extra_guest_fee DECIMAL(10, 2) DEFAULT 0.00,
    price_per_night DECIMAL(10, 2) NOT NULL,
    bed_type VARCHAR(50) COMMENT 'e.g., King, Queen, Twin',
    bed_count INT DEFAULT 1,
    room_size_sqft INT,
    has_balcony BOOLEAN DEFAULT FALSE,
    has_window BOOLEAN DEFAULT TRUE,
    floor_number INT,
    room_status ENUM('AVAILABLE', 'OCCUPIED', 'MAINTENANCE', 'BLOCKED') DEFAULT 'AVAILABLE',
    is_active BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (property_id) REFERENCES PROPERTY(property_id) ON DELETE CASCADE,
    FOREIGN KEY (created_by_employee_id) REFERENCES EMPLOYEE(employee_id) ON DELETE SET NULL,
    FOREIGN KEY (updated_by_employee_id) REFERENCES EMPLOYEE(employee_id) ON DELETE SET NULL,
    INDEX idx_property_id (property_id),
    INDEX idx_room_status (room_status),
    INDEX idx_room_number (room_number),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB COMMENT='Individual rooms within properties';

-- Room Images
CREATE TABLE ROOM_IMAGE (
    image_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    room_id BIGINT NOT NULL,
    image_url VARCHAR(512) NOT NULL,
    image_caption VARCHAR(255),
    display_order INT DEFAULT 0,
    is_primary BOOLEAN DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (room_id) REFERENCES ROOM(room_id) ON DELETE CASCADE,
    INDEX idx_room_id (room_id),
    INDEX idx_display_order (display_order)
) ENGINE=InnoDB COMMENT='Room images';

-- Room Amenities
CREATE TABLE ROOM_AMENITIES (
    room_amenity_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    room_id BIGINT NOT NULL,
    amenity_name VARCHAR(100),
    amenity_icon VARCHAR(255),
    is_available BOOLEAN DEFAULT TRUE,
    notes VARCHAR(255),
    FOREIGN KEY (room_id) REFERENCES ROOM(room_id) ON DELETE CASCADE,
    INDEX idx_room_id (room_id)
) ENGINE=InnoDB COMMENT='Amenities specific to rooms';

-- ============================================
-- COUPON TABLE
-- ============================================

-- System-wide Coupons
CREATE TABLE COUPON (
    coupon_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    coupon_code VARCHAR(50) NOT NULL UNIQUE,
    coupon_name VARCHAR(255),
    description TEXT,
    discount_type ENUM('PERCENTAGE', 'FIXED_AMOUNT') NOT NULL,
    discount_value DECIMAL(10, 2) NOT NULL,
    max_discount_amount DECIMAL(10, 2),
    min_booking_amount DECIMAL(10, 2),
    valid_from DATE,
    valid_until DATE,
    usage_limit INT COMMENT 'Total times this coupon can be used',
    usage_limit_per_user INT DEFAULT 1,
    used_count INT DEFAULT 0,
    applicable_to VARCHAR(100) COMMENT 'ALL, FIRST_BOOKING, SPECIFIC_PROPERTIES',
    applicable_user_type VARCHAR(50) COMMENT 'ALL, NEW_USER, EXISTING_USER',
    is_active BOOLEAN DEFAULT TRUE,
    created_by_admin_id BIGINT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by_admin_id) REFERENCES ADMIN(admin_id) ON DELETE SET NULL,
    INDEX idx_coupon_code (coupon_code),
    INDEX idx_is_active (is_active),
    INDEX idx_valid_dates (valid_from, valid_until)
) ENGINE=InnoDB COMMENT='System-wide discount coupons';

-- ============================================
-- BOOKING TABLES
-- ============================================

-- Main Bookings Table
CREATE TABLE BOOKING (
    booking_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    booking_reference VARCHAR(50) UNIQUE NOT NULL,
    property_id BIGINT NOT NULL,
    room_id BIGINT,
    guest_id BIGINT NOT NULL,
    coupon_id BIGINT,
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    number_of_guests INT NOT NULL,
    number_of_adults INT DEFAULT 1,
    number_of_children INT DEFAULT 0,
    number_of_infants INT DEFAULT 0,
    number_of_nights INT NOT NULL,
    base_price DECIMAL(12, 2) NOT NULL,
    extra_guest_charges DECIMAL(12, 2) DEFAULT 0.00,
    cleaning_fee DECIMAL(12, 2) DEFAULT 0.00,
    service_fee DECIMAL(12, 2) DEFAULT 0.00,
    discount_amount DECIMAL(12, 2) DEFAULT 0.00,
    tax_amount DECIMAL(12, 2) DEFAULT 0.00,
    total_amount DECIMAL(12, 2) NOT NULL,
    booking_status ENUM('PENDING', 'CONFIRMED', 'CHECKED_IN', 'CHECKED_OUT', 'CANCELLED', 'REFUNDED', 'NO_SHOW') DEFAULT 'PENDING',
    payment_status ENUM('PENDING', 'PARTIAL', 'PAID', 'REFUNDED') DEFAULT 'PENDING',
    special_requests TEXT,
    cancellation_reason TEXT,
    cancelled_at DATETIME,
    cancelled_by BIGINT,
    refund_amount DECIMAL(12, 2),
    refund_processed_at DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    confirmed_at DATETIME,
    checked_in_at DATETIME,
    checked_out_at DATETIME,
    FOREIGN KEY (property_id) REFERENCES PROPERTY(property_id) ON DELETE CASCADE,
    FOREIGN KEY (room_id) REFERENCES ROOM(room_id) ON DELETE SET NULL,
    FOREIGN KEY (guest_id) REFERENCES GUEST(guest_id) ON DELETE CASCADE,
    FOREIGN KEY (coupon_id) REFERENCES COUPON(coupon_id) ON DELETE SET NULL,
    FOREIGN KEY (cancelled_by) REFERENCES USER(user_id) ON DELETE SET NULL,
    INDEX idx_booking_reference (booking_reference),
    INDEX idx_property_id (property_id),
    INDEX idx_room_id (room_id),
    INDEX idx_guest_id (guest_id),
    INDEX idx_booking_status (booking_status),
    INDEX idx_payment_status (payment_status),
    INDEX idx_check_in_date (check_in_date),
    INDEX idx_check_out_date (check_out_date),
    INDEX idx_dates (check_in_date, check_out_date),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB COMMENT='Property bookings';

-- Additional Guests in Booking
CREATE TABLE BOOKING_GUEST (
    booking_guest_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    booking_id BIGINT NOT NULL,
    guest_full_name VARCHAR(255) NOT NULL,
    guest_email VARCHAR(255),
    guest_phone VARCHAR(20),
    guest_age INT,
    guest_id_proof_type VARCHAR(50) COMMENT 'e.g., Passport, Aadhar, Driver License',
    guest_id_proof_number VARCHAR(100),
    relationship_to_booker VARCHAR(100),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES BOOKING(booking_id) ON DELETE CASCADE,
    INDEX idx_booking_id (booking_id)
) ENGINE=InnoDB COMMENT='Additional guests in a booking';

-- ============================================
-- PAYMENT TABLE
-- ============================================

-- Payments for Bookings
CREATE TABLE PAYMENT (
    payment_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    payment_reference VARCHAR(50) UNIQUE NOT NULL,
    booking_id BIGINT NOT NULL,
    guest_id BIGINT NOT NULL,
    amount DECIMAL(12, 2) NOT NULL,
    payment_method ENUM('CREDIT_CARD', 'DEBIT_CARD', 'UPI', 'NET_BANKING', 'WALLET', 'CASH', 'BANK_TRANSFER') NOT NULL,
    payment_type ENUM('BOOKING', 'REFUND', 'PARTIAL') DEFAULT 'BOOKING',
    payment_status ENUM('PENDING', 'PROCESSING', 'SUCCESS', 'FAILED', 'REFUNDED', 'CANCELLED') DEFAULT 'PENDING',
    transaction_id VARCHAR(255) UNIQUE,
    payment_gateway VARCHAR(100) COMMENT 'e.g., Razorpay, Stripe, PayPal',
    gateway_response TEXT,
    refund_amount DECIMAL(12, 2),
    refund_date DATETIME,
    refund_reason TEXT,
    refund_transaction_id VARCHAR(255),
    payment_date DATETIME,
    currency VARCHAR(10) DEFAULT 'INR',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES BOOKING(booking_id) ON DELETE CASCADE,
    FOREIGN KEY (guest_id) REFERENCES GUEST(guest_id) ON DELETE CASCADE,
    INDEX idx_payment_reference (payment_reference),
    INDEX idx_booking_id (booking_id),
    INDEX idx_guest_id (guest_id),
    INDEX idx_payment_status (payment_status),
    INDEX idx_transaction_id (transaction_id),
    INDEX idx_payment_date (payment_date)
) ENGINE=InnoDB COMMENT='Payment transactions';

-- ============================================
-- REVIEW TABLE
-- ============================================

-- Property Reviews
CREATE TABLE REVIEW (
    review_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    booking_id BIGINT NOT NULL UNIQUE,
    property_id BIGINT NOT NULL,
    guest_id BIGINT NOT NULL,
    overall_rating DECIMAL(3, 2) NOT NULL CHECK (overall_rating >= 0 AND overall_rating <= 5),
    cleanliness_rating DECIMAL(3, 2) CHECK (cleanliness_rating >= 0 AND cleanliness_rating <= 5),
    accuracy_rating DECIMAL(3, 2) CHECK (accuracy_rating >= 0 AND accuracy_rating <= 5),
    communication_rating DECIMAL(3, 2) CHECK (communication_rating >= 0 AND communication_rating <= 5),
    location_rating DECIMAL(3, 2) CHECK (location_rating >= 0 AND location_rating <= 5),
    value_rating DECIMAL(3, 2) CHECK (value_rating >= 0 AND value_rating <= 5),
    check_in_rating DECIMAL(3, 2) CHECK (check_in_rating >= 0 AND check_in_rating <= 5),
    review_title VARCHAR(255),
    review_text TEXT,
    host_response TEXT,
    host_response_date DATETIME,
    is_verified BOOLEAN DEFAULT FALSE,
    is_visible BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE,
    helpful_count INT DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES BOOKING(booking_id) ON DELETE CASCADE,
    FOREIGN KEY (property_id) REFERENCES PROPERTY(property_id) ON DELETE CASCADE,
    FOREIGN KEY (guest_id) REFERENCES GUEST(guest_id) ON DELETE CASCADE,
    INDEX idx_booking_id (booking_id),
    INDEX idx_property_id (property_id),
    INDEX idx_guest_id (guest_id),
    INDEX idx_overall_rating (overall_rating),
    INDEX idx_is_visible (is_visible),
    INDEX idx_is_featured (is_featured),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB COMMENT='Property reviews and ratings';

-- ============================================
-- WISHLIST TABLE
-- ============================================

-- Guest Wishlists
CREATE TABLE WISHLIST (
    wishlist_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    guest_id BIGINT NOT NULL,
    property_id BIGINT NOT NULL,
    notes TEXT,
    added_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (guest_id) REFERENCES GUEST(guest_id) ON DELETE CASCADE,
    FOREIGN KEY (property_id) REFERENCES PROPERTY(property_id) ON DELETE CASCADE,
    UNIQUE KEY unique_wishlist (guest_id, property_id),
    INDEX idx_guest_id (guest_id),
    INDEX idx_property_id (property_id),
    INDEX idx_added_at (added_at)
) ENGINE=InnoDB COMMENT='Guest property wishlists';

-- ============================================
-- NOTIFICATION TABLE
-- ============================================

-- User Notifications
CREATE TABLE NOTIFICATION (
    notification_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    notification_type VARCHAR(50) COMMENT 'e.g., BOOKING_CONFIRMED, PAYMENT_SUCCESS, MESSAGE',
    notification_channel VARCHAR(50) DEFAULT 'IN_APP' COMMENT 'IN_APP, EMAIL, SMS, PUSH',
    title VARCHAR(255),
    message TEXT,
    action_url VARCHAR(512),
    is_read BOOLEAN DEFAULT FALSE,
    related_entity_type VARCHAR(50) COMMENT 'e.g., BOOKING, PAYMENT, REVIEW',
    related_entity_id BIGINT,
    priority VARCHAR(20) DEFAULT 'NORMAL' COMMENT 'LOW, NORMAL, HIGH, URGENT',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    read_at DATETIME,
    sent_at DATETIME,
    FOREIGN KEY (user_id) REFERENCES USER(user_id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_is_read (is_read),
    INDEX idx_notification_type (notification_type),
    INDEX idx_created_at (created_at),
    INDEX idx_priority (priority)
) ENGINE=InnoDB COMMENT='User notifications';

-- ============================================
-- MESSAGING TABLE
-- ============================================



