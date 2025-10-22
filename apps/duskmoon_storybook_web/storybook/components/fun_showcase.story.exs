defmodule Storybook.Components.FunShowcase do
  use PhoenixStorybook.Story, :page

  def description, do: "Interactive and visual fun components that add delight to your applications."

  def imports do
    [
      {PhoenixDuskmoon.Component, [
        dm_btn: 1, dm_card: 1, dm_tab: 1, dm_modal: 1, dm_appbar: 1,
        dm_mdi: 1, dm_breadcrumb: 1, dm_page_header: 1, dm_dropdown: 1
      ]},
      {PhoenixDuskmoon.Component.Fun, [
        dm_fun_spotlight_search: 1, dm_fun_plasma_ball: 1, dm_fun_eclipse: 1,
        dm_fun_snow: 1, dm_fun_signature: 1, dm_fun_button_noise: 1
      ]},
      {PhoenixDuskmoon.Modal, [dm_show_modal: 0]}
    ]
  end

  def variations do
    [
      %{
        id: :showcase,
        description: "Interactive fun components showcase",
        template: """
        <div class="container mx-auto p-6 space-y-8">
          <!-- Page Header -->
          <.dm_page_header>
            <:title>Fun Components Showcase</:title>
            <:subtitle>Interactive and visual components that bring delight to your UI</:subtitle>
            <:actions>
              <.dm_btn variant="outline" phx-click="toggle_theme">
                <.dm_mdi>theme-light-dark</.dm_mdi>
                Toggle Theme
              </.dm_btn>
            </:actions>
          </.dm_page_header>

          <!-- Spotlight Search Demo -->
          <.dm_card class="p-6">
            <:header>
              <div class="flex items-center space-x-2">
                <.dm_mdi>search-web</.dm_mdi>
                <h3>Spotlight Search</h3>
              </div>
            </:header>
            <:content>
              <p class="text-base-content/70 mb-4">
                Press ⌘+K (or Ctrl+K) to open the spotlight search. This is a powerful command palette that can search through your application, navigate to different sections, or trigger actions.
              </p>

              <div class="flex items-center space-x-4">
                <.dm_btn variant="primary" phx-click="open_spotlight">
                  <.dm_mdi>search</.dm_mdi>
                  Open Spotlight (⌘+K)
                </.dm_btn>
                <.dm_btn variant="ghost" phx-click="open_spotlight_simple">
                  <.dm_mdi>text-search</.dm_mdi>
                  Simple Version
                </.dm_btn>
              </div>

              <div class="mt-6">
                <.dm_fun_spotlight_search id="demo-spotlight" placeholder="Search or command..." shortcut="⌘+K">
                  <:suggestion icon="search" label="Search Users" description="Find team members and profiles" action="navigate_users" />
                  <:suggestion icon="file" label="Search Documents" description="Browse files and reports" action="navigate_docs" />
                  <:suggestion icon="settings" label="Search Settings" description="Configure application preferences" action="navigate_settings" />
                  <:suggestion icon="home" label="Dashboard" description="Go to main dashboard" action="navigate_dashboard" />
                  <:suggestion icon="user" label="Profile" description="View your profile" action="navigate_profile" />
                  <:suggestion icon="bell" label="Notifications" description="Check your notifications" action="navigate_notifications" />
                  <:suggestion icon="help-circle" label="Help Center" description="Get help and support" action="navigate_help" />
                  <:suggestion icon="plus" label="New Project" description="Create a new project" action="create_project" />
                  <:suggestion icon="upload" label="Upload File" description="Upload a new file" action="upload_file" />
                </.dm_fun_spotlight_search>
              </div>
            </:content>
          </.dm_card>

          <!-- Visual Effects -->
          <.dm_tab id="visual-effects" selected_tab="plasma">
            <:tab id="plasma" label="Plasma Ball">
              <.dm_card class="p-6">
                <:header>
                  <div class="flex items-center space-x-2">
                    <.dm_mdi>creation</.dm_mdi>
                    <h3>Plasma Ball Effect</h3>
                  </div>
                </:header>
                <:content>
                  <p class="text-base-content/70 mb-4">
                    An interactive plasma ball visualization that responds to mouse movements. Click to add energy bursts!
                  </p>

                  <div class="flex items-center space-x-4 mb-4">
                    <.dm_btn variant="primary" phx-click="start_plasma">
                      <.dm_mdi>play</.dm_mdi>
                      Start Animation
                    </.dm_btn>
                    <.dm_btn variant="outline" phx-click="stop_plasma">
                      <.dm_mdi>stop</.dm_mdi>
                      Stop Animation
                    </.dm_btn>
                    <.dm_btn variant="ghost" phx-click="reset_plasma">
                      <.dm_mdi>refresh</.dm_mdi>
                      Reset
                    </.dm_btn>
                  </div>

                  <div class="bg-base-200 rounded-lg p-4 flex items-center justify-center h-96">
                    <.dm_fun_plasma_ball id="plasma-demo" interactive={true} />
                  </div>
                </:content>
              </.dm_card>
            </:tab>

            <:tab id="eclipse" label="Eclipse">
              <.dm_card class="p-6">
                <:header>
                  <div class="flex items-center space-x-2">
                    <.dm_mdi>weather-eclipse</.dm_mdi>
                    <h3>Eclipse Animation</h3>
                  </div>
                </:header>
                <:content>
                  <p class="text-base-content/70 mb-4">
                    A mesmerizing eclipse animation with customizable colors and speeds. Perfect for loading screens or ambient animations.
                  </p>

                  <div class="flex items-center space-x-4 mb-4">
                    <.dm_btn variant="primary" phx-click="start_eclipse">
                      <.dm_mdi>play</.dm_mdi>
                      Start Eclipse
                    </.dm_btn>
                    <.dm_dropdown>
                      <:trigger>
                        <.dm_btn variant="outline">
                          <.dm_mdi>palette</.dm_mdi>
                          Change Colors
                        </.dm_btn>
                      </:trigger>
                      <:content>
                        <.dm_btn variant="ghost" phx-click="eclipse_theme_solar">Solar Theme</.dm_btn>
                        <.dm_btn variant="ghost" phx-click="eclipse_theme_lunar">Lunar Theme</.dm_btn>
                        <.dm_btn variant="ghost" phx-click="eclipse_theme_aurora">Aurora Theme</.dm_btn>
                      </:content>
                    </.dm_dropdown>
                    <.dm_btn variant="ghost" phx-click="eclipse_speed">
                      <.dm_mdi>speedometer</.dm_mdi>
                      Speed: <span id="eclipse-speed-text">Normal</span>
                    </.dm_btn>
                  </div>

                  <div class="bg-base-900 rounded-lg p-4 flex items-center justify-center h-96">
                    <.dm_fun_eclipse id="eclipse-demo" />
                  </div>
                </:content>
              </.dm_card>
            </:tab>

            <:tab id="snow" label="Snow">
              <.dm_card class="p-6">
                <:header>
                  <div class="flex items-center space-x-2">
                    <.dm_mdi>snowflake</.dm_mdi>
                    <h3>Snow Animation</h3>
                  </div>
                </:header>
                <:content>
                  <p class="text-base-content/70 mb-4">
                    A gentle snow animation that creates a peaceful atmosphere. Adjustable intensity and speed.
                  </p>

                  <div class="flex items-center space-x-4 mb-4">
                    <.dm_btn variant="primary" phx-click="start_snow">
                      <.dm_mdi>play</.dm_mdi>
                      Start Snow
                    </.dm_btn>
                    <.dm_btn variant="outline" phx-click="snow_light">
                      <.dm_mdi>weather-snowy</.dm_mdi>
                      Light Snow
                    </.dm_btn>
                    <.dm_btn variant="outline" phx-click="snow_heavy">
                      <.dm_mdi>weather-blizzard</.dm_mdi>
                      Heavy Snow
                    </.dm_btn>
                    <.dm_btn variant="ghost" phx-click="stop_snow">
                      <.dm_mdi>stop</.dm_mdi>
                      Stop
                    </.dm_btn>
                  </div>

                  <div class="bg-gradient-to-b from-sky-100 to-sky-50 rounded-lg p-4 relative h-96 overflow-hidden">
                    <div class="absolute inset-0 flex items-center justify-center">
                      <div class="text-center">
                        <.dm_mdi class="text-6xl text-sky-400">pine-tree</.dm_mdi>
                        <p class="mt-2 text-sky-700">Winter Wonderland</p>
                      </div>
                    </div>
                    <.dm_fun_snow id="snow-demo" />
                  </div>
                </:content>
              </.dm_card>
            </:tab>
          </.dm_tab>

          <!-- Interactive Components -->
          <.dm_tab id="interactive" selected_tab="signature">
            <:tab id="signature" label="Signature Pad">
              <.dm_card class="p-6">
                <:header>
                  <div class="flex items-center space-x-2">
                    <.dm_mdi>draw</.dm_mdi>
                    <h3>Signature Pad</h3>
                  </div>
                </:header>
                <:content>
                  <p class="text-base-content/70 mb-4">
                    A smooth signature pad that captures mouse and touch input. Perfect for signatures, drawings, or annotations.
                  </p>

                  <div class="flex items-center space-x-4 mb-4">
                    <.dm_btn variant="primary" phx-click="save_signature">
                      <.dm_mdi>content-save</.dm_mdi>
                      Save Signature
                    </.dm_btn>
                    <.dm_btn variant="outline" phx-click="clear_signature">
                      <.dm_mdi>eraser</.dm_mdi>
                      Clear
                    </.dm_btn>
                    <.dm_dropdown>
                      <:trigger>
                        <.dm_btn variant="ghost">
                          <.dm_mdi>palette-outline</.dm_mdi>
                          Pen Color
                        </.dm_btn>
                      </:trigger>
                      <:content>
                        <.dm_btn variant="ghost" phx-click="signature_color_black">Black</.dm_btn>
                        <.dm_btn variant="ghost" phx-click="signature_color_blue">Blue</.dm_btn>
                        <.dm_btn variant="ghost" phx-click="signature_color_red">Red</.dm_btn>
                      </:content>
                    </.dm_dropdown>
                    <.dm_btn variant="ghost" phx-click="signature_thin">
                      <.dm_mdi>pencil-outline</.dm_mdi>
                      Thin Pen
                    </.dm_btn>
                    <.dm_btn variant="ghost" phx-click="signature_thick">
                      <.dm_mdi>brush</.dm_mdi>
                      Thick Pen
                    </.dm_btn>
                  </div>

                  <div class="bg-white border-2 border-base-300 rounded-lg">
                    <.dm_fun_signature id="signature-demo" />
                  </div>
                </:content>
              </.dm_card>
            </:tab>

            <:tab id="button-noise" label="Button Noise">
              <.dm_card class="p-6">
                <:header>
                  <div class="flex items-center space-x-2">
                    <.dm_mdi>gesture-tap-button</.dm_mdi>
                    <h3>Button Noise Effects</h3>
                  </div>
                </:header>
                <:content>
                  <p class="text-base-content/70 mb-4">
                    Interactive buttons with particle noise effects when clicked. Great for adding visual feedback and delight.
                  </p>

                  <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
                    <div class="text-center space-y-2">
                      <.dm_fun_button_noise id="noise-burst" variant="burst" class="w-full">
                        <.dm_mdi>star</.dm_mdi>
                        Burst
                      </.dm_fun_button_noise>
                      <span class="text-sm">Burst Effect</span>
                    </div>

                    <div class="text-center space-y-2">
                      <.dm_fun_button_noise id="noise-sparkle" variant="sparkle" class="w-full">
                        <.dm_mdi>star-four-points</.dm_mdi>
                        Sparkle
                      </.dm_fun_button_noise>
                      <span class="text-sm">Sparkle Effect</span>
                    </div>

                    <div class="text-center space-y-2">
                      <.dm_fun_button_noise id="noise-confetti" variant="confetti" class="w-full">
                        <.dm_mdi>confetti</.dm_mdi>
                        Confetti
                      </.dm_fun_button_noise>
                      <span class="text-sm">Confetti Effect</span>
                    </div>

                    <div class="text-center space-y-2">
                      <.dm_fun_button_noise id="noise-ripple" variant="ripple" class="w-full">
                        <.dm_mdi>water</.dm_mdi>
                        Ripple
                      </.dm_fun_button_noise>
                      <span class="text-sm">Ripple Effect</span>
                    </div>
                  </div>

                  <div class="mt-6 p-4 bg-base-200 rounded-lg">
                    <p class="text-sm font-medium mb-2">Custom Colors:</p>
                    <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
                      <.dm_fun_button_noise id="noise-rainbow" variant="rainbow" class="w-full">
                        <.dm_mdi>rainbow</.dm_mdi>
                        Rainbow
                      </.dm_fun_button_noise>

                      <.dm_fun_button_noise id="noise-gold" variant="gold" class="w-full">
                        <.dm_mdi>star</.dm_mdi>
                        Gold Stars
                      </.dm_fun_button_noise>

                      <.dm_fun_button_noise id="noise-hearts" variant="hearts" class="w-full">
                        <.dm_mdi>heart</.dm_mdi>
                        Hearts
                      </.dm_fun_button_noise>

                      <.dm_fun_button_noise id="noise-music" variant="music" class="w-full">
                        <.dm_mdi>music-note</.dm_mdi>
                        Music Notes
                      </.dm_fun_button_noise>
                    </div>
                  </div>
                </:content>
              </.dm_card>
            </:tab>
          </.dm_tab>

          <!-- Real World Examples -->
          <.dm_card class="p-6">
            <:header>
              <div class="flex items-center space-x-2">
                <.dm_mdi>application</.dm_mdi>
                <h3>Real World Examples</h3>
              </div>
            </:header>
            <:content>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <!-- Example 1: Dashboard with Spotlight -->
                <div class="space-y-4">
                  <h4 class="font-medium">Dashboard Navigation</h4>
                  <div class="bg-base-100 border rounded-lg p-4">
                    <div class="flex items-center justify-between mb-4">
                      <h5 class="font-medium">My Dashboard</h5>
                      <.dm_btn variant="ghost" size="sm" phx-click="open_spotlight_dashboard">
                        <.dm_mdi>search</.dm_mdi>
                        ⌘+K
                      </.dm_btn>
                    </div>
                    <p class="text-sm text-base-content/70">
                      Use the spotlight search to quickly navigate to different sections,
                      search for content, or trigger actions without touching your mouse.
                    </p>
                    <.dm_fun_spotlight_search id="dashboard-spotlight" placeholder="Quick navigation...">
                      <:suggestion icon="view-dashboard" label="Dashboard" description="Main dashboard view" />
                      <:suggestion icon="account" label="Profile" description="Your profile settings" />
                      <:suggestion icon="chart-line" label="Analytics" description="View analytics data" />
                    </.dm_fun_spotlight_search>
                  </div>
                </div>

                <!-- Example 2: Form with Signature -->
                <div class="space-y-4">
                  <h4 class="font-medium">Document Signing</h4>
                  <div class="bg-base-100 border rounded-lg p-4">
                    <div class="flex items-center justify-between mb-4">
                      <h5 class="font-medium">Contract Agreement</h5>
                      <span class="text-sm text-base-content/50">Ready to sign</span>
                    </div>
                    <p class="text-sm text-base-content/70 mb-4">
                      Please sign below to confirm your agreement to the terms and conditions.
                    </p>
                    <div class="bg-white border rounded p-2 mb-4">
                      <.dm_fun_signature id="contract-signature" height="100" />
                    </div>
                    <div class="flex space-x-2">
                      <.dm_btn variant="primary" size="sm">
                        <.dm_mdi>check</.dm_mdi>
                        Sign Document
                      </.dm_btn>
                      <.dm_btn variant="ghost" size="sm" phx-click="clear_contract_signature">
                        <.dm_mdi>refresh</.dm_midi>
                        Clear
                      </.dm_btn>
                    </div>
                  </div>
                </div>

                <!-- Example 3: Loading with Effects -->
                <div class="space-y-4">
                  <h4 class="font-medium">Loading States</h4>
                  <div class="bg-base-100 border rounded-lg p-4">
                    <div class="flex items-center justify-between mb-4">
                      <h5 class="font-medium">Processing Request</h5>
                      <span class="text-sm text-warning">In Progress</span>
                    </div>
                    <p class="text-sm text-base-content/70 mb-4">
                      Your request is being processed. Enjoy the visual effects while you wait!
                    </p>
                    <div class="bg-base-200 rounded p-4 flex items-center justify-center h-32">
                      <.dm_fun_plasma_ball id="loading-plasma" size="small" />
                    </div>
                  </div>
                </div>

                <!-- Example 4: Interactive Buttons -->
                <div class="space-y-4">
                  <h4 class="font-medium">Gamified Actions</h4>
                  <div class="bg-base-100 border rounded-lg p-4">
                    <div class="flex items-center justify-between mb-4">
                      <h5 class="font-medium">Achievement Unlocked!</h5>
                      <span class="text-sm text-success">New</span>
                    </div>
                    <p class="text-sm text-base-content/70 mb-4">
                      Click the buttons below to see delightful particle effects!
                    </p>
                    <div class="space-y-2">
                      <.dm_fun_button_noise id="achievement-burst" variant="burst" class="w-full">
                        <.dm_mdi>trophy</.dm_mdi>
                        Claim Achievement
                      </.dm_fun_button_noise>
                      <.dm_fun_button_noise id="achievement-sparkle" variant="sparkle" class="w-full">
                        <.dm_mdi>star</.dm_mdi>
                        Share Progress
                      </.dm_fun_button_noise>
                    </div>
                  </div>
                </div>
              </div>
            </:content>
          </.dm_card>

          <!-- Performance Tips -->
          <.dm_card class="p-6">
            <:header>
              <div class="flex items-center space-x-2">
                <.dm_mdi>lightbulb</.dm_mdi>
                <h3>Performance & Best Practices</h3>
              </div>
            </:header>
            <:content>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <h4 class="font-medium mb-2">Performance Considerations</h4>
                  <ul class="space-y-1 text-sm text-base-content/70">
                    <li class="flex items-start space-x-2">
                      <.dm_mdi class="text-success mt-0.5">check-circle</.dm_mdi>
                      <span>Use sparingly to avoid overwhelming users</span>
                    </li>
                    <li class="flex items-start space-x-2">
                      <.dm_mdi class="text-success mt-0.5">check-circle</.dm_mdi>
                      <span>Consider device capabilities and battery life</span>
                    </li>
                    <li class="flex items-start space-x-2">
                      <.dm_mdi class="text-success mt-0.5">check-circle</.dm_midi>
                      <span>Provide options to disable animations</span>
                    </li>
                    <li class="flex items-start space-x-2">
                      <.dm_mdi class="text-warning mt-0.5">alert</.dm_mdi>
                      <span>Test performance on lower-end devices</span>
                    </li>
                  </ul>
                </div>

                <div>
                  <h4 class="font-medium mb-2">UX Guidelines</h4>
                  <ul class="space-y-1 text-sm text-base-content/70">
                    <li class="flex items-start space-x-2">
                      <.dm_mdi class="text-success mt-0.5">check-circle</.dm_mdi>
                      <span>Animations should enhance, not distract</span>
                    </li>
                    <li class="flex items-start space-x-2">
                      <.dm_mdi class="text-success mt-0.5">check-circle</.dm_mdi>
                      <span>Keep animations subtle and purposeful</span>
                    </li>
                    <li class="flex items-start space-x-2">
                      <.dm_mdi class="text-success mt-0.5">check-circle</.dm_mdi>
                      <span>Respect user preferences for reduced motion</span>
                    </li>
                    <li class="flex items-start space-x-2">
                      <.dm_mdi class="text-info mt-0.5">information</.dm_mdi>
                      <span>Use to provide visual feedback and delight</span>
                    </li>
                  </ul>
                </div>
              </div>
            </:content>
          </.dm_card>
        </div>
        """
      }
    ]
  end
end