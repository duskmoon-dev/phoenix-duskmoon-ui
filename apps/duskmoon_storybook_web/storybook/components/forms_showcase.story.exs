defmodule Storybook.Components.FormsShowcase do
  use PhoenixStorybook.Story, :page

  def description, do: "A comprehensive showcase of all form components working together in real-world scenarios."

  def imports do
    [
      {PhoenixDuskmoon.Component, [
        dm_btn: 1, dm_card: 1, dm_form: 1, dm_tab: 1, dm_modal: 1,
        dm_loading: 1, dm_mdi: 1, dm_breadcrumb: 1, dm_page_header: 1
      ]},
      {Phoenix.HTML.Form, [form_for: 4, label: 2, text_input: 2, email_input: 2, password_input: 2, textarea: 2, select: 4, checkbox: 3, radio_button: 4]}
    ]
  end

  def variations do
    [
      %{
        id: :showcase,
        description: "Complete forms showcase with multiple examples",
        template: """
        <div class="container mx-auto p-6 space-y-8">
          <!-- Page Header -->
          <.dm_page_header>
            <:title>Forms Showcase</:title>
            <:subtitle>Comprehensive demonstration of Phoenix Duskmoon UI form components</:subtitle>
            <:actions>
              <.dm_btn variant="primary" phx-click="show_guide">
                <.dm_mdi name="help-circle" />
                View Guide
              </.dm_btn>
            </:actions>
          </.dm_page_header>

          <!-- Breadcrumb -->
          <.dm_breadcrumb>
            <:item href="/">Home</:item>
            <:item href="/components">Components</:item>
            <:item active>Forms Showcase</:item>
          </.dm_breadcrumb>

          <!-- Tab Navigation -->
          <.dm_tab id="forms-tabs" selected_tab="user-profile">
            <:tab id="user-profile" label="User Profile">
              <div class="space-y-6">
                <.dm_form for={%{}} as={:user_profile} phx-submit="save_profile" class="space-y-4">
                  <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                      <label class="block text-sm font-medium mb-2">First Name</label>
                      <.dm_form_dm_input
                        form={:user_profile}
                        field={:first_name}
                        placeholder="Enter first name"
                        left_icon="account"
                        right_icon="pencil"
                      />
                    </div>
                    <div>
                      <label class="block text-sm font-medium mb-2">Last Name</label>
                      <.dm_form_dm_input
                        form={:user_profile}
                        field={:last_name}
                        placeholder="Enter last name"
                        left_icon="account-outline"
                      />
                    </div>
                  </div>

                  <div>
                    <label class="block text-sm font-medium mb-2">Email Address</label>
                    <.dm_form_dm_input
                      form={:user_profile}
                      field={:email}
                      type="email"
                      placeholder="user@example.com"
                      left_icon="email"
                      right_icon="check"
                    />
                  </div>

                  <div>
                    <label class="block text-sm font-medium mb-2">Bio</label>
                    <.dm_form_dm_textarea
                      form={:user_profile}
                      field={:bio}
                      placeholder="Tell us about yourself..."
                      rows="4"
                    />
                  </div>

                  <div class="flex items-center space-x-2">
                    <.dm_form_dm_switch form={:user_profile} field={:newsletter} label="Subscribe to newsletter" />
                  </div>

                  <div class="flex items-center space-x-4">
                    <.dm_btn variant="primary" type="submit" loading={@loading_profile}>
                      <.dm_mdi name="content-save" />
                      Save Profile
                    </.dm_btn>
                    <.dm_btn variant="ghost" type="button">
                      <.dm_mdi name="cancel" />
                      Cancel
                    </.dm_btn>
                  </div>
                </.dm_form>
              </div>
            </:tab>

            <:tab id="preferences" label="Preferences">
              <div class="space-y-6">
                <.dm_form for={%{}} as={:preferences} phx-submit="save_preferences" class="space-y-4">
                  <div>
                    <label class="block text-sm font-medium mb-2">Theme</label>
                    <.dm_form_dm_select form={:preferences} field={:theme}>
                      <option value="light">Light Mode</option>
                      <option value="dark">Dark Mode</option>
                      <option value="auto">Auto</option>
                    </.dm_form_dm_select>
                  </div>

                  <div>
                    <label class="block text-sm font-medium mb-2">Language</label>
                    <.dm_form_dm_select form={:preferences} field={:language}>
                      <option value="en">English</option>
                      <option value="es">Español</option>
                      <option value="fr">Français</option>
                      <option value="de">Deutsch</option>
                    </.dm_form_dm_select>
                  </div>

                  <div>
                    <label class="block text-sm font-medium mb-2">Notification Preferences</label>
                    <div class="space-y-2">
                      <.dm_form_dm_checkbox form={:preferences} field={:email_notifications} label="Email notifications" />
                      <.dm_form_dm_checkbox form={:preferences} field={:push_notifications} label="Push notifications" />
                      <.dm_form_dm_checkbox form={:preferences} field={:sms_notifications} label="SMS notifications" />
                    </div>
                  </div>

                  <div>
                    <label class="block text-sm font-medium mb-2">Font Size</label>
                    <div class="space-y-2">
                      <.dm_form_dm_radio form={:preferences} field={:font_size} value="small" label="Small" />
                      <.dm_form_dm_radio form={:preferences} field={:font_size} value="medium" label="Medium" />
                      <.dm_form_dm_radio form={:preferences} field={:font_size} value="large" label="Large" />
                    </div>
                  </div>

                  <div>
                    <label class="block text-sm font-medium mb-2">UI Density</label>
                    <.dm_form_dm_slider form={:preferences} field={:density} min="0" max="100" value="50" />
                  </div>

                  <div class="flex items-center space-x-4">
                    <.dm_btn variant="primary" type="submit">
                      <.dm_mdi name="content-save" />
                      Save Preferences
                    </.dm_btn>
                    <.dm_btn variant="outline" type="button">
                      <.dm_mdi name="restore" />
                      Reset to Defaults
                    </.dm_btn>
                  </div>
                </.dm_form>
              </div>
            </:tab>

            <:tab id="advanced" label="Advanced Features">
              <div class="space-y-6">
                <.dm_card class="p-6">
                  <:header><h3>Interactive Components</h3></:header>

                  <div class="space-y-6">
                    <div>
                      <label class="block text-sm font-medium mb-2">Search with Suggestions</label>
                      <.dm_form_dm_search_with_suggestions
                        placeholder="Search for users..."
                        suggestions={[
                          %{icon: "account", label: "John Doe", description: "john@example.com"},
                          %{icon: "account", label: "Jane Smith", description: "jane@example.com"}
                        ]}
                      />
                    </div>

                    <div>
                      <label class="block text-sm font-medium mb-2">Password with Strength Indicator</label>
                      <.dm_form_dm_password_strength form={%{}} field={:password} />
                    </div>

                    <div>
                      <label class="block text-sm font-medium mb-2">Date Range Selection</label>
                      <.dm_form_dm_datepicker form={%{}} field={:start_date} placeholder="Start date" />
                      <.dm_form_dm_datepicker form={%{}} field={:end_date} placeholder="End date" />
                    </div>

                    <div>
                      <label class="block text-sm font-medium mb-2">Time Selection</label>
                      <.dm_form_dm_timepicker form={%{}} field={:time} />
                    </div>

                    <div>
                      <label class="block text-sm font-medium mb-2">Color Picker</label>
                      <.dm_form_dm_color_picker form={%{}} field={:color} />
                    </div>

                    <div>
                      <label class="block text-sm font-medium mb-2">File Upload</label>
                      <.dm_form_dm_file_upload form={%{}} field={:file} />
                    </div>

                    <div>
                      <label class="block text-sm font-medium mb-2">Rich Text Editor</label>
                      <.dm_form_dm_rich_text form={%{}} field={:content} />
                    </div>

                    <div>
                      <label class="block text-sm font-medium mb-2">Tags Input</label>
                      <.dm_form_dm_tags form={%{}} field={:tags} />
                    </div>

                    <div>
                      <label class="block text-sm font-medium mb-2">Rating</label>
                      <.dm_form_dm_rating form={%{}} field={:rating} max={5} />
                    </div>

                    <div>
                      <label class="block text-sm font-medium mb-2">Range Slider</label>
                      <.dm_form_dm_range_slider form={%{}} field={:range} min={0} max={100} />
                    </div>

                    <div>
                      <label class="block text-sm font-medium mb-2">Signature</label>
                      <.dm_form_dm_signature form={%{}} field={:signature} />
                    </div>
                  </div>
                </.dm_card>
              </div>
            </:tab>

            <:tab id="validation" label="Validation & States">
              <div class="space-y-6">
                <.dm_card class="p-6">
                  <:header><h3>Form Validation Examples</h3></:header>

                  <div class="space-y-4">
                    <div>
                      <label class="block text-sm font-medium mb-2">Valid Input</label>
                      <.dm_form_dm_input
                        form={%{}}
                        field={:valid_field}
                        value="john@example.com"
                        valid={true}
                        right_icon="check-circle"
                      />
                    </div>

                    <div>
                      <label class="block text-sm font-medium mb-2">Invalid Input</label>
                      <.dm_form_dm_input
                        form={%{}}
                        field={:invalid_field}
                        value="invalid-email"
                        error="Please enter a valid email address"
                        right_icon="alert-circle"
                      />
                    </div>

                    <div>
                      <label class="block text-sm font-medium mb-2">Warning State</label>
                      <.dm_form_dm_input
                        form={%{}}
                        field={:warning_field}
                        value="weak-password"
                        warning="This password is weak"
                        right_icon="alert"
                      />
                    </div>

                    <div>
                      <label class="block text-sm font-medium mb-2">Disabled Input</label>
                      <.dm_form_dm_input
                        form={%{}}
                        field={:disabled_field}
                        value="Read only"
                        disabled={true}
                      />
                    </div>

                    <div>
                      <label class="block text-sm font-medium mb-2">Loading Input</label>
                      <.dm_form_dm_input
                        form={%{}}
                        field={:loading_field}
                        placeholder="Validating..."
                        loading={true}
                      />
                    </div>

                    <div>
                      <label class="block text-sm font-medium mb-2">Compact Input</label>
                      <.dm_form_dm_compact_input
                        form={%{}}
                        field={:compact_field}
                        placeholder="Compact version"
                      />
                    </div>
                  </div>
                </.dm_card>
              </div>
            </:tab>

            <:tab id="layouts" label="Form Layouts">
              <div class="space-y-6">
                <.dm_card class="p-6">
                  <:header><h3>Multi-Column Layout</h3></:header>

                  <.dm_form for={%{}} as={:multi_column} class="space-y-4">
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                      <div>
                        <label class="block text-sm font-medium mb-2">City</label>
                        <.dm_form_dm_input form={:multi_column} field={:city} placeholder="City" />
                      </div>
                      <div>
                        <label class="block text-sm font-medium mb-2">State</label>
                        <.dm_form_dm_select form={:multi_column} field={:state}>
                          <option value="">Select state</option>
                          <option value="CA">California</option>
                          <option value="NY">New York</option>
                          <option value="TX">Texas</option>
                        </.dm_form_dm_select>
                      </div>
                      <div>
                        <label class="block text-sm font-medium mb-2">ZIP Code</label>
                        <.dm_form_dm_input form={:multi_column} field={:zip} placeholder="ZIP" />
                      </div>
                    </div>
                  </.dm_form>
                </.dm_card>

                <.dm_card class="p-6">
                  <:header><h3>Inline Form</h3></:header>

                  <.dm_form for={%{}} as={:inline} class="flex items-center space-x-4">
                    <.dm_form_dm_input form={:inline} field={:search} placeholder="Search..." />
                    <.dm_form_dm_select form={:inline} field={:category}>
                      <option value="">All categories</option>
                      <option value="users">Users</option>
                      <option value="posts">Posts</option>
                      <option value="comments">Comments</option>
                    </.dm_form_dm_select>
                    <.dm_btn variant="primary" type="submit">
                      <.dm_mdi name="search" />
                      Search
                    </.dm_btn>
                  </.dm_form>
                </.dm_card>

                <.dm_card class="p-6">
                  <:header><h3>Wizard Steps</h3></:header>

                  <div class="space-y-4">
                    <div class="flex items-center justify-between">
                      <div class="flex items-center space-x-2">
                        <div class="w-8 h-8 bg-primary text-primary-content rounded-full flex items-center justify-center text-sm font-medium">1</div>
                        <span class="text-sm font-medium">Personal Info</span>
                      </div>
                      <div class="flex items-center space-x-2">
                        <div class="w-8 h-8 bg-base-300 text-base-content rounded-full flex items-center justify-center text-sm font-medium">2</div>
                        <span class="text-sm text-base-content/60">Preferences</span>
                      </div>
                      <div class="flex items-center space-x-2">
                        <div class="w-8 h-8 bg-base-300 text-base-content rounded-full flex items-center justify-center text-sm font-medium">3</div>
                        <span class="text-sm text-base-content/60">Review</span>
                      </div>
                    </div>

                    <.dm_form for={%{}} as={:wizard} class="space-y-4">
                      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <.dm_form_dm_input form={:wizard} field={:first_name} placeholder="First name" />
                        <.dm_form_dm_input form={:wizard} field={:last_name} placeholder="Last name" />
                      </div>
                      <div class="flex justify-between">
                        <.dm_btn variant="ghost" disabled>
                          <.dm_mdi name="arrow-left" />
                          Previous
                        </.dm_btn>
                        <.dm_btn variant="primary">
                          Next
                          <.dm_mdi name="arrow-right" />
                        </.dm_btn>
                      </div>
                    </.dm_form>
                  </div>
                </.dm_card>
              </div>
            </:tab>
          </.dm_tab>
        </div>
        """
      }
    ]
  end
end