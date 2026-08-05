# XML Layout Implementation Plan

This plan outlines the creation of three fragment layouts (`login`, `sign_up`, `reset_password`) and necessary drawable resources to match the provided design requirements.

## Proposed Changes

### [Drawables]
Create background resources for buttons and input fields to ensure a consistent, rounded appearance as requested.

#### [NEW] [bg_button_black.xml](file:///C:/Users/LG/OneDrive/Desktop/FrontEnt_new/app/src/main/res/drawable/bg_button_black.xml)
- Solid color: `@color/whs_black`
- Corners: Rounded (e.g., 8dp or fully rounded depending on design)

#### [NEW] [bg_edittext.xml](file:///C:/Users/LG/OneDrive/Desktop/FrontEnt_new/app/src/main/res/drawable/bg_edittext.xml)
- Background color: White or very light gray
- Stroke: Light gray border
- Corners: Rounded (e.g., 8dp)

### [Layouts]
Implement the three fragment layouts using `ConstraintLayout`.

#### [NEW] [fragment_login.xml](file:///C:/Users/LG/OneDrive/Desktop/FrontEnt_new/app/src/main/res/layout/fragment_login.xml)
- Logo: `logo_black`
- Title and Subtitle
- Email and Password input fields with labels
- "Forgot Password" link
- Login button
- Sign-up redirection text

#### [NEW] [fragment_sign_up.xml](file:///C:/Users/LG/OneDrive/Desktop/FrontEnt_new/app/src/main/res/layout/fragment_sign_up.xml)
- Back navigation button
- "Sign Up" title and subtitle
- Fields: Name, Email, Phone, Password
- "Sign Up and Start" button

#### [NEW] [fragment_reset_password.xml](file:///C:/Users/LG/OneDrive/Desktop/FrontEnt_new/app/src/main/res/layout/fragment_reset_password.xml)
- Back navigation button
- "Forgot Password" title and subtitle
- Email input field
- "Send Reset Link" button (fixed to bottom)

## Verification Plan

### Automated Tests
- Build the project to ensure XML validity and resource references.

### Manual Verification
- Render previews in Android Studio (if possible) or deploy to a device to check alignment and styling.
