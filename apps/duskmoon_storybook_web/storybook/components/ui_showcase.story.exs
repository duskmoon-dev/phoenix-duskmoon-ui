defmodule Storybook.Components.UIShowcase do
  use PhoenixStorybook.Story, :page

  def description, do: "Complete UI showcase demonstrating utility components in real-world contexts and layouts."

  def imports do
    [
      {PhoenixDuskmoon.Component, [
        dm_btn: 1, dm_card: 1, dm_tab: 1, dm_modal: 1, dm_appbar: 1,
        dm_mdi: 1, dm_breadcrumb: 1, dm_page_header: 1, dm_dropdown: 1,
        dm_avatar: 1, dm_badge: 1, dm_divider: 1, dm_link: 1,
        dm_loading: 1, dm_progress: 1, dm_tooltip: 1, dm_table: 1,
        dm_pagination: 1, dm_navbar: 1, dm_actionbar: 1, dm_left_menu: 1,
        dm_markdown: 1, dm_flash: 1, dm_skeleton: 1, dm_page_footer: 1
      ]}
    ]
  end

  def variations do
    [
      %{
        id: :showcase,
        description: "Comprehensive UI components showcase in real-world contexts",
        template: """
        <div class="container mx-auto p-6 space-y-8">
          <!-- Page Header with Breadcrumb -->
          <.dm_page_header>
            <:title>UI Components Showcase</:title>
            <:subtitle>Real-world examples of utility components working together in complete interfaces</:subtitle>
            <:actions>
              <.dm_btn variant="outline" phx-click="show_code">
                <.dm_mdi name="code-tags" />
                View Code
              </.dm_btn>
              <.dm_btn variant="primary" phx-click="download_example">
                <.dm_mdi name="download" />
                Download Template
              </.dm_btn>
            </:actions>
          </.dm_page_header>

          <.dm_breadcrumb>
            <:item href="/">Home</:item>
            <:item href="/components">Components</:item>
            <:item active>UI Showcase</:item>
          </.dm_breadcrumb>

          <!-- Complete Application Layout -->
          <.dm_card class="overflow-hidden">
            <:header>
              <h3 class="text-lg font-semibold">Complete Application Layout</h3>
              <p class="text-sm text-base-content/70">Full app layout with navigation, content, and interactions</p>
            </:header>

            <div class="min-h-[600px] bg-base-50">
              <!-- App Bar -->
              <.dm_appbar>
                <:brand>
                  <div class="flex items-center space-x-2">
                    <.dm_mdi name="rocket" class="text-2xl" />
                    <span class="font-bold">DemoApp</span>
                  </div>
                </:brand>

                <:nav>
                  <.dm_navbar>
                    <:item href="#" active>Dashboard</:item>
                    <:item href="#">Projects</:item>
                    <:item href="#">Team</:item>
                    <:item href="#">Analytics</:item>
                    <:item href="#">Settings</:item>
                  </.dm_navbar>
                </:nav>

                <:actions>
                  <.dm_btn variant="ghost" size="sm">
                    <.dm_mdi name="search" />
                  </.dm_btn>
                  <.dm_btn variant="ghost" size="sm">
                    <.dm_mdi name="bell" />
                    <.dm_badge variant="error" size="xs">3</.dm_badge>
                  </.dm_btn>
                  <.dm_dropdown>
                    <:trigger>
                      <.dm_btn variant="ghost" size="sm">
                        <.dm_avatar size="sm" src="https://picsum.photos/seed/user1/40/40.jpg" />
                      </.dm_btn>
                    </:trigger>
                    <:content>
                      <div class="p-2">
                        <p class="text-sm font-medium">John Doe</p>
                        <p class="text-xs text-base-content/50">john@example.com</p>
                      </div>
                      <.dm_divider />
                      <.dm_btn variant="ghost" size="sm" class="w-full justify-start">
                        <.dm_mdi name="account" />
                        Profile
                      </.dm_btn>
                      <.dm_btn variant="ghost" size="sm" class="w-full justify-start">
                        <.dm_mdi name="settings" />
                        Settings
                      </.dm_btn>
                      <.dm_btn variant="ghost" size="sm" class="w-full justify-start">
                        <.dm_mdi name="logout" />
                        Logout
                      </.dm_btn>
                    </:content>
                  </.dm_dropdown>
                </:actions>
              </.dm_appbar>

              <div class="flex h-[500px]">
                <!-- Sidebar Menu -->
                <div class="w-64 bg-base-100 border-r">
                  <.dm_left_menu>
                    <:group label="Main">
                      <:item icon="view-dashboard" href="#" active>Overview</:item>
                      <:item icon="chart-line" href="#">Analytics</:item>
                      <:item icon="file-document" href="#">Reports</:item>
                    </:group>
                    <:group label="Projects">
                      <:item icon="folder" href="#">All Projects</:item>
                      <:item icon="plus" href="#">New Project</:item>
                      <:item icon="star" href="#">Starred</:item>
                    </:group>
                    <:group label="Team">
                      <:item icon="account-group" href="#">Members</:item>
                      <:item icon="calendar" href="#">Schedule</:item>
                      <:item icon="message" href="#">Messages</:item>
                    </:group>
                  </.dm_left_menu>
                </div>

                <!-- Main Content -->
                <div class="flex-1 overflow-auto">
                  <!-- Action Bar -->
                  <.dm_actionbar>
                    <div class="flex items-center justify-between">
                      <div class="flex items-center space-x-4">
                        <h2 class="text-xl font-semibold">Dashboard Overview</h2>
                        <.dm_badge variant="success">Live</.dm_badge>
                      </div>
                      <div class="flex items-center space-x-2">
                        <.dm_btn variant="outline" size="sm">
                          <.dm_mdi name="download" />
                          Export
                        </.dm_btn>
                        <.dm_btn variant="primary" size="sm">
                          <.dm_mdi name="plus" />
                          New Project
                        </.dm_btn>
                      </div>
                    </div>
                  </.dm_actionbar>

                  <!-- Flash Messages -->
                  <div class="p-4 space-y-2">
                    <.dm_flash kind="info" title="Welcome!">
                      This is a demo dashboard showcasing UI components working together.
                    </.dm_flash>
                    <.dm_flash kind="success" title="Recent Activity">
                      Your last report was generated successfully.
                    </.dm_flash>
                  </div>

                  <!-- Dashboard Content -->
                  <div class="p-4 space-y-6">
                    <!-- Stats Cards -->
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                      <.dm_card class="p-4">
                        <div class="flex items-center justify-between">
                          <div>
                            <p class="text-sm text-base-content/50">Total Projects</p>
                            <p class="text-2xl font-bold">24</p>
                            <p class="text-sm text-success">+12% from last month</p>
                          </div>
                          <.dm_mdi name="folder" class="text-3xl text-primary" />
                        </div>
                      </.dm_card>

                      <.dm_card class="p-4">
                        <div class="flex items-center justify-between">
                          <div>
                            <p class="text-sm text-base-content/50">Active Users</p>
                            <p class="text-2xl font-bold">142</p>
                            <p class="text-sm text-success">+8% from last week</p>
                          </div>
                          <.dm_mdi name="account-group" class="text-3xl text-success" />
                        </div>
                      </.dm_card>

                      <.dm_card class="p-4">
                        <div class="flex items-center justify-between">
                          <div>
                            <p class="text-sm text-base-content/50">Revenue</p>
                            <p class="text-2xl font-bold">$12,450</p>
                            <p class="text-sm text-error">-3% from last month</p>
                          </div>
                          <.dm_mdi name="currency-usd" class="text-3xl text-warning" />
                        </div>
                      </.dm_card>
                    </div>

                    <!-- Recent Activity Table -->
                    <.dm_card class="p-4">
                      <:header>
                        <h3 class="font-semibold">Recent Activity</h3>
                      </:header>
                      <:content>
                        <.dm_table>
                          <thead>
                            <tr>
                              <th>User</th>
                              <th>Action</th>
                              <th>Time</th>
                              <th>Status</th>
                            </tr>
                          </thead>
                          <tbody>
                            <tr>
                              <td>
                                <div class="flex items-center space-x-2">
                                  <.dm_avatar size="sm" src="https://picsum.photos/seed/user1/32/32.jpg" />
                                  <span class="text-sm">Alice Johnson</span>
                                </div>
                              </td>
                              <td>Created new project</td>
                              <td>2 hours ago</td>
                              <td><.dm_badge variant="success">Completed</.dm_badge></td>
                            </tr>
                            <tr>
                              <td>
                                <div class="flex items-center space-x-2">
                                  <.dm_avatar size="sm" src="https://picsum.photos/seed/user2/32/32.jpg" />
                                  <span class="text-sm">Bob Smith</span>
                                </div>
                              </td>
                              <td>Updated dashboard</td>
                              <td>5 hours ago</td>
                              <td><.dm_badge variant="success">Completed</.dm_badge></td>
                            </tr>
                            <tr>
                              <td>
                                <div class="flex items-center space-x-2">
                                  <.dm_avatar size="sm" src="https://picsum.photos/seed/user3/32/32.jpg" />
                                  <span class="text-sm">Carol White</span>
                                </div>
                              </td>
                              <td>Uploaded files</td>
                              <td>1 day ago</td>
                              <td><.dm_badge variant="warning">In Progress</.dm_badge></td>
                            </tr>
                          </tbody>
                        </.dm_table>

                        <!-- Pagination -->
                        <div class="flex items-center justify-between mt-4">
                          <p class="text-sm text-base-content/50">Showing 1-10 of 24 activities</p>
                          <.dm_pagination current_page={1} total_pages={3} />
                        </div>
                      </:content>
                    </.dm_card>
                  </div>
                </div>
              </div>

              <!-- Page Footer -->
              <.dm_page_footer>
                <div class="flex items-center justify-between text-sm text-base-content/50">
                  <p>&copy; 2024 DemoApp. All rights reserved.</p>
                  <div class="flex items-center space-x-4">
                    <.dm_link href="#">Privacy</.dm_link>
                    <.dm_link href="#">Terms</.dm_link>
                    <.dm_link href="#">Support</.dm_link>
                  </div>
                </div>
              </.dm_page_footer>
            </div>
          </.dm_card>

          <!-- Component Patterns Showcase -->
          <.dm_tab id="patterns" selected_tab="cards">
            <:tab id="cards" label="Card Patterns">
              <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                <!-- Profile Card -->
                <.dm_card class="overflow-hidden">
                  <div class="h-32 bg-gradient-to-r from-primary to-secondary"></div>
                  <div class="p-4 -mt-12">
                    <div class="flex justify-center">
                      <.dm_avatar size="xl" src="https://picsum.photos/seed/profile1/96/96.jpg" class="ring-4 ring-base-100" />
                    </div>
                    <div class="text-center mt-4">
                      <h4 class="font-semibold">Sarah Chen</h4>
                      <p class="text-sm text-base-content/50">Product Designer</p>
                      <div class="flex justify-center items-center space-x-2 mt-2">
                        <.dm_mdi name="map-marker" class="text-sm" />
                        <span class="text-sm">San Francisco</span>
                      </div>
                    </div>
                    <:footer>
                      <div class="flex space-x-2">
                        <.dm_btn variant="outline" size="sm" class="flex-1">
                          <.dm_mdi name="message" />
                          Message
                        </.dm_btn>
                        <.dm_btn variant="primary" size="sm" class="flex-1">
                          <.dm_mdi name="account-plus" />
                          Follow
                        </.dm_btn>
                      </div>
                    </:footer>
                  </div>
                </.dm_card>

                <!-- Stats Card -->
                <.dm_card>
                  <:header>
                    <div class="flex items-center justify-between">
                      <h4 class="font-semibold">Monthly Revenue</h4>
                      <.dm_tooltip content="View detailed analytics">
                        <.dm_btn variant="ghost" size="sm">
                          <.dm_mdi name="information" />
                        </.dm_btn>
                      </.dm_tooltip>
                    </div>
                  </:header>
                  <div class="space-y-4">
                    <div class="flex items-baseline space-x-2">
                      <span class="text-3xl font-bold">$24,582</span>
                      <span class="text-sm text-success">+18.2%</span>
                    </div>
                    <div class="h-2 bg-base-200 rounded-full overflow-hidden">
                      <div class="h-full bg-success w-3/4"></div>
                    </div>
                    <div class="flex justify-between text-xs text-base-content/50">
                      <span>$0</span>
                      <span>Goal: $30,000</span>
                    </div>
                  </div>
                </.dm_card>

                <!-- Task Card -->
                <.dm_card>
                  <:header>
                    <div class="flex items-center justify-between">
                      <h4 class="font-semibold">Active Tasks</h4>
                      <.dm_badge variant="info">12</.dm_badge>
                    </div>
                  </:header>
                  <div class="space-y-2">
                    <div class="flex items-center space-x-2">
                      <input type="checkbox" class="checkbox checkbox-sm" checked />
                      <span class="text-sm line-through text-base-content/50">Setup database</span>
                    </div>
                    <div class="flex items-center space-x-2">
                      <input type="checkbox" class="checkbox checkbox-sm" />
                      <span class="text-sm">Design new landing page</span>
                    </div>
                    <div class="flex items-center space-x-2">
                      <input type="checkbox" class="checkbox checkbox-sm" />
                      <span class="text-sm">Review pull requests</span>
                    </div>
                    <div class="flex items-center space-x-2">
                      <input type="checkbox" class="checkbox checkbox-sm" />
                      <span class="text-sm">Update documentation</span>
                    </div>
                  </div>
                  <:footer>
                    <.dm_btn variant="outline" size="sm" class="w-full">
                      <.dm_mdi name="plus" />
                      Add Task
                    </.dm_btn>
                  </:footer>
                </.dm_card>
              </div>
            </:tab>

            <:tab id="forms" label="Form Patterns">
              <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                <!-- Search and Filter -->
                <.dm_card class="p-4">
                  <:header><h4 class="font-semibold">Search & Filter</h4></:header>
                  <div class="space-y-4">
                    <div class="relative">
                      <input type="text" placeholder="Search projects..." class="input input-bordered w-full pl-10" />
                      <.dm_mdi name="search" class="absolute left-3 top-1/2 -translate-y-1/2 text-base-content/50" />
                    </div>
                    <div class="flex flex-wrap gap-2">
                      <.dm_badge variant="primary" removable>Design</.dm_badge>
                      <.dm_badge variant="secondary" removable>Development</.dm_badge>
                      <.dm_badge variant="outline" removable>+2 more</.dm_badge>
                    </div>
                    <div class="grid grid-cols-2 gap-2">
                      <select class="select select-bordered select-sm">
                        <option>Status</option>
                        <option>Active</option>
                        <option>Completed</option>
                      </select>
                      <select class="select select-bordered select-sm">
                        <option>Sort by</option>
                        <option>Recent</option>
                        <option>Name</option>
                      </select>
                    </div>
                  </div>
                </.dm_card>

                <!-- Quick Actions -->
                <.dm_card class="p-4">
                  <:header><h4 class="font-semibold">Quick Actions</h4></:header>
                  <div class="grid grid-cols-2 gap-2">
                    <.dm_btn variant="outline" size="sm" class="flex flex-col h-16">
                      <.dm_mdi name="plus" class="text-xl" />
                      <span class="text-xs">New Project</span>
                    </.dm_btn>
                    <.dm_btn variant="outline" size="sm" class="flex flex-col h-16">
                      <.dm_mdi name="upload" class="text-xl" />
                      <span class="text-xs">Upload</span>
                    </.dm_btn>
                    <.dm_btn variant="outline" size="sm" class="flex flex-col h-16">
                      <.dm_mdi name="share" class="text-xl" />
                      <span class="text-xs">Share</span>
                    </.dm_btn>
                    <.dm_btn variant="outline" size="sm" class="flex flex-col h-16">
                      <.dm_mdi name="download" class="text-xl" />
                      <span class="text-xs">Export</span>
                    </.dm_btn>
                  </div>
                </.dm_card>

                <!-- Inline Form -->
                <.dm_card class="p-4">
                  <:header><h4 class="font-semibold">Inline Form</h4></:header>
                  <div class="space-y-4">
                    <div class="flex items-center space-x-2">
                      <input type="text" placeholder="Enter email" class="input input-bordered input-sm flex-1" />
                      <select class="select select-bordered select-sm">
                        <option>Role</option>
                        <option>Admin</option>
                        <option>Editor</option>
                        <option>Viewer</option>
                      </select>
                      <.dm_btn variant="primary" size="sm">
                        <.dm_mdi name="plus" />
                        Add
                      </.dm_btn>
                    </div>
                  </div>
                </.dm_card>

                <!-- Settings Panel -->
                <.dm_card class="p-4">
                  <:header><h4 class="font-semibold">Settings Panel</h4></:header>
                  <div class="space-y-3">
                    <div class="flex items-center justify-between">
                      <span class="text-sm">Email notifications</span>
                      <input type="checkbox" class="toggle toggle-sm" checked />
                    </div>
                    <div class="flex items-center justify-between">
                      <span class="text-sm">Push notifications</span>
                      <input type="checkbox" class="toggle toggle-sm" />
                    </div>
                    <div class="flex items-center justify-between">
                      <span class="text-sm">Dark mode</span>
                      <input type="checkbox" class="toggle toggle-sm" />
                    </div>
                    <div class="flex items-center justify-between">
                      <span class="text-sm">Compact view</span>
                      <input type="checkbox" class="toggle toggle-sm" checked />
                    </div>
                  </div>
                </.dm_card>
              </div>
            </:tab>

            <:tab id="loading" label="Loading States">
              <div class="space-y-6">
                <!-- Skeleton Examples -->
                <.dm_card class="p-4">
                  <:header><h4 class="font-semibold">Skeleton Loading</h4></:header>
                  <div class="space-y-4">
                    <div class="space-y-2">
                      <.dm_skeleton class="h-4 w-3/4" />
                      <.dm_skeleton class="h-4 w-1/2" />
                    </div>
                    <div class="flex items-center space-x-4">
                      <.dm_skeleton class="w-12 h-12 rounded-full" />
                      <div class="flex-1 space-y-2">
                        <.dm_skeleton class="h-4 w-1/4" />
                        <.dm_skeleton class="h-3 w-1/3" />
                      </div>
                    </div>
                    <div class="space-y-2">
                      <.dm_skeleton class="h-32 w-full" />
                      <.dm_skeleton class="h-4 w-full" />
                      <.dm_skeleton class="h-4 w-2/3" />
                    </div>
                  </div>
                </.dm_card>

                <!-- Progress Indicators -->
                <.dm_card class="p-4">
                  <:header><h4 class="font-semibold">Progress Indicators</h4></:header>
                  <div class="space-y-4">
                    <div>
                      <div class="flex justify-between text-sm mb-1">
                        <span>Uploading files...</span>
                        <span>65%</span>
                      </div>
                      <.dm_progress value={65} max={100} />
                    </div>
                    <div>
                      <div class="flex justify-between text-sm mb-1">
                        <span>Processing data...</span>
                        <span>40%</span>
                      </div>
                      <.dm_progress value={40} max={100} variant="warning" />
                    </div>
                    <div>
                      <div class="flex justify-between text-sm mb-1">
                        <span>Generating report...</span>
                        <span>90%</span>
                      </div>
                      <.dm_progress value={90} max={100} variant="success" />
                    </div>
                  </div>
                </.dm_card>

                <!-- Loading Spinners -->
                <.dm_card class="p-4">
                  <:header><h4 class="font-semibold">Loading Spinners</h4></:header>
                  <div class="flex items-center space-x-6">
                    <div class="text-center">
                      <.dm_loading size="sm" />
                      <p class="text-xs mt-1">Small</p>
                    </div>
                    <div class="text-center">
                      <.dm_loading size="md" />
                      <p class="text-xs mt-1">Medium</p>
                    </div>
                    <div class="text-center">
                      <.dm_loading size="lg" />
                      <p class="text-xs mt-1">Large</p>
                    </div>
                    <div class="text-center">
                      <.dm_loading size="lg" variant="dots" />
                      <p class="text-xs mt-1">Dots</p>
                    </div>
                  </div>
                </.dm_card>
              </div>
            </:tab>

            <:tab id="feedback" label="Feedback & Messages">
              <div class="space-y-6">
                <!-- Toast Messages -->
                <div class="space-y-2">
                  <.dm_flash kind="success" title="Success!" removable>
                    Your changes have been saved successfully.
                  </.dm_flash>
                  <.dm_flash kind="info" title="Information">
                    A new version is available. Click to update.
                  </.dm_flash>
                  <.dm_flash kind="warning" title="Warning">
                    Your session will expire in 5 minutes.
                  </.dm_flash>
                  <.dm_flash kind="error" title="Error" removable>
                    Failed to upload file. Please try again.
                  </.dm_flash>
                </div>

                <!-- Status Badges -->
                <.dm_card class="p-4">
                  <:header><h4 class="font-semibold">Status Indicators</h4></:header>
                  <div class="flex flex-wrap gap-2">
                    <.dm_badge variant="success">Online</.dm_badge>
                    <.dm_badge variant="warning">Away</.dm_badge>
                    <.dm_badge variant="error">Offline</:dm_badge>
                    <.dm_badge variant="info">New</.dm_badge>
                    <.dm_badge variant="primary">Pro</:dm_badge>
                    <.dm_badge variant="secondary">Beta</:dm_badge>
                    <.dm_badge variant="outline">Draft</:dm_badge>
                    <.dm_badge variant="ghost">Archived</:dm_badge>
                  </div>
                </.dm_card>

                <!-- Tooltips -->
                <.dm_card class="p-4">
                  <:header><h4 class="font-semibold">Tooltips & Help</h4></:header>
                  <div class="flex items-center space-x-4">
                    <.dm_tooltip content="Click to save your work">
                      <.dm_btn variant="outline" size="sm">
                        <.dm_mdi name="content-save" />
                        Save
                      </.dm_btn>
                    </.dm_tooltip>
                    <.dm_tooltip content="Export as PDF">
                      <.dm_btn variant="outline" size="sm">
                        <.dm_mdi name="file-pdf" />
                        Export
                      </.dm_btn>
                    </.dm_tooltip>
                    <.dm_tooltip content="Share with your team">
                      <.dm_btn variant="outline" size="sm">
                        <.dm_mdi name="share" />
                        Share
                      </.dm_btn>
                    </.dm_tooltip>
                  </div>
                </.dm_card>
              </div>
            </:tab>
          </.dm_tab>

          <!-- Best Practices -->
          <.dm_card class="p-6">
            <:header>
              <div class="flex items-center space-x-2">
                <.dm_mdi name="lightbulb" />
                <h3 class="text-lg font-semibold">Best Practices & Guidelines</h3>
              </div>
            </:header>
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              <div>
                <h4 class="font-medium mb-2">Consistency</h4>
                <p class="text-sm text-base-content/70">
                  Use consistent spacing, colors, and component sizes throughout your application.
                </p>
              </div>
              <div>
                <h4 class="font-medium mb-2">Accessibility</h4>
                <p class="text-sm text-base-content/70">
                  Ensure all interactive elements are keyboard accessible and have proper ARIA labels.
                </p>
              </div>
              <div>
                <h4 class="font-medium mb-2">Responsive Design</h4>
                <p class="text-sm text-base-content/70">
                  Test components on different screen sizes and ensure proper mobile experience.
                </p>
              </div>
              <div>
                <h4 class="font-medium mb-2">Loading States</h4>
                <p class="text-sm text-base-content/70">
                  Always provide feedback during data fetching and processing operations.
                </p>
              </div>
              <div>
                <h4 class="font-medium mb-2">Error Handling</h4>
                <p class="text-sm text-base-content/70">
                  Display clear error messages and provide recovery options when possible.
                </p>
              </div>
              <div>
                <h4 class="font-medium mb-2">Performance</h4>
                <p class="text-sm text-base-content/70">
                  Optimize component rendering and minimize unnecessary re-renders.
                </p>
              </div>
            </div>
          </.dm_card>
        </div>
        """
      }
    ]
  end
end