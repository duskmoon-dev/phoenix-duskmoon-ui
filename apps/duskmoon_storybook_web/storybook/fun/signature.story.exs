defmodule Storybook.Fun.Signature do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.CssArt.Signature.dm_art_signature/1
  def description, do: "CSS art animated handwriting signature effect."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          id: "signature-default",
          content: "A"
        },
        template: """
        <div class="bg-white border-2 border-gray-200 rounded-lg p-8 relative h-48">
          <p class="text-gray-600 text-sm mb-4">Document content here...</p>
          <.dm_art_signature id="signature-default" content="A" />
        </div>
        """
      },
      %Variation{
        id: :approved,
        attributes: %{
          id: "signature-approved",
          content: "Approved",
          size: "medium",
          color: "#0066cc",
          rotation: -15
        },
        template: """
        <div class="bg-white border-2 border-gray-200 rounded-lg p-8 relative h-48">
          <p class="text-gray-600 text-sm mb-4">Purchase Order #12345</p>
          <p class="text-gray-600 text-sm mb-4">Total: $1,234.56</p>
          <.dm_art_signature id="signature-approved" content="Approved" size="medium" color="#0066cc" rotation="-15" />
        </div>
        """
      },
      %Variation{
        id: :verified,
        attributes: %{
          id: "signature-verified",
          content: "✓",
          size: "large",
          color: "#16a34a",
          rotation: 0
        },
        template: """
        <div class="bg-white border-2 border-gray-200 rounded-lg p-8 relative h-48">
          <p class="text-gray-600 text-sm mb-4">Certificate of Authenticity</p>
          <p class="text-gray-600 text-sm mb-4">This document has been verified</p>
          <.dm_art_signature id="signature-verified" content="✓" size="large" color="#16a34a" rotation="0" />
        </div>
        """
      },
      %Variation{
        id: :star_seal,
        attributes: %{
          id: "signature-star",
          content: "★",
          size: "large",
          color: "#fbbf24",
          rotation: 0
        },
        template: """
        <div class="bg-gradient-to-br from-blue-50 to-indigo-100 rounded-lg p-8 relative h-48">
          <p class="text-indigo-800 text-sm mb-4">Premium Quality Certified</p>
          <p class="text-indigo-600 text-sm mb-4">5-Star Rating</p>
          <.dm_art_signature id="signature-star" content="★" size="large" color="#fbbf24" rotation="0" />
        </div>
        """
      },
      %Variation{
        id: :rejected,
        attributes: %{
          id: "signature-rejected",
          content: "REJECTED",
          size: "medium",
          color: "#dc2626",
          rotation: 45,
          opacity: 0.8
        },
        template: """
        <div class="bg-white border-2 border-gray-200 rounded-lg p-8 relative h-48">
          <p class="text-gray-600 text-sm mb-4">Application for Review</p>
          <p class="text-gray-600 text-sm mb-4">Status: Under consideration</p>
          <.dm_art_signature id="signature-rejected" content="REJECTED" size="medium" color="#dc2626" rotation="45" opacity="0.8" />
        </div>
        """
      },
      %Variation{
        id: :confidential,
        attributes: %{
          id: "signature-confidential",
          content: "CONFIDENTIAL",
          size: "medium",
          color: "#7c3aed",
          rotation: -30,
          opacity: 0.6
        },
        template: """
        <div class="bg-white border-2 border-gray-200 rounded-lg p-8 relative h-48">
          <p class="text-gray-600 text-sm mb-4">Internal Document</p>
          <p class="text-gray-600 text-sm mb-4">For authorized eyes only</p>
          <.dm_art_signature id="signature-confidential" content="CONFIDENTIAL" size="medium" color="#7c3aed" rotation="-30" opacity="0.6" />
        </div>
        """
      },
      %Variation{
        id: :watermark,
        attributes: %{
          id: "signature-watermark",
          content: "DRAFT",
          size: "large",
          color: "#9ca3af",
          rotation: -45,
          opacity: 0.3,
          top: "50%",
          right: "50%",
          position: "fixed"
        },
        template: """
        <div class="bg-white border-2 border-gray-200 rounded-lg p-8 relative h-48 overflow-hidden">
          <p class="text-gray-600 text-sm mb-4">Project Proposal</p>
          <p class="text-gray-600 text-sm mb-4">Version 1.0 - Not for distribution</p>
          <.dm_art_signature id="signature-watermark" content="DRAFT" size="large" color="#9ca3af" rotation="-45" opacity="0.3" top="50%" right="50%" position="fixed" />
        </div>
        """
      },
      %Variation{
        id: :priority,
        attributes: %{
          id: "signature-priority",
          content: "URGENT",
          size: "medium",
          color: "#ea580c",
          rotation: 0,
          opacity: 0.9
        },
        template: """
        <div class="bg-red-50 border-2 border-red-200 rounded-lg p-8 relative h-48">
          <p class="text-red-800 text-sm mb-4">High Priority Memo</p>
          <p class="text-red-600 text-sm mb-4">Immediate attention required</p>
          <.dm_art_signature id="signature-priority" content="URGENT" size="medium" color="#ea580c" rotation="0" opacity="0.9" />
        </div>
        """
      },
      %Variation{
        id: :custom_placement,
        attributes: %{
          id: "signature-custom",
          content: "Initial",
          size: "small",
          color: "#059669",
          rotation: -20,
          right: "1rem",
          top: "1rem"
        },
        template: """
        <div class="bg-white border-2 border-gray-200 rounded-lg p-8 relative h-48">
          <p class="text-gray-600 text-sm mb-4">Contract Agreement</p>
          <p class="text-gray-600 text-sm mb-4">Please initial here to confirm</p>
          <.dm_art_signature id="signature-custom" content="Initial" size="small" color="#059669" rotation="-20" right="1rem" top="1rem" />
        </div>
        """
      },
      %Variation{
        id: :multiple_signatures,
        template: """
        <div class="bg-white border-2 border-gray-200 rounded-lg p-8 relative h-64">
          <p class="text-gray-600 text-sm mb-4">Multi-Party Agreement</p>
          <p class="text-gray-600 text-sm mb-4">This document requires multiple approvals</p>

          <!-- First signature -->
          <.dm_art_signature
            id="sig-1"
            content="Approved ✓"
            size="small"
            color="#16a34a"
            rotation="-15"
            right="8rem"
            top="3rem"
          />

          <!-- Second signature -->
          <.dm_art_signature
            id="sig-2"
            content="Reviewed"
            size="small"
            color="#2563eb"
            rotation="-25"
            right="2rem"
            top="5rem"
          />

          <!-- Third signature -->
          <.dm_art_signature
            id="sig-3"
            content="★"
            size="medium"
            color="#fbbf24"
            rotation="0"
            right="6rem"
            top="7rem"
          />
        </div>
        """
      },
      %Variation{
        id: :size_comparison,
        template: """
        <div class="bg-gray-50 border-2 border-gray-200 rounded-lg p-8 relative h-64">
          <p class="text-gray-600 text-sm mb-4">Signature Size Comparison</p>

          <!-- Small signature -->
          <.dm_art_signature
            id="sig-small"
            content="Small"
            size="small"
            color="#6366f1"
            rotation="-15"
            right="1rem"
            top="1rem"
          />

          <!-- Medium signature -->
          <.dm_art_signature
            id="sig-medium"
            content="Medium"
            size="medium"
            color="#8b5cf6"
            rotation="-20"
            right="8rem"
            top="3rem"
          />

          <!-- Large signature -->
          <.dm_art_signature
            id="sig-large"
            content="Large"
            size="large"
            color="#ec4899"
            rotation="-25"
            right="4rem"
            top="8rem"
          />
        </div>
        """
      },
      %Variation{
        id: :diploma_example,
        template: """
        <div class="bg-gradient-to-br from-amber-50 to-yellow-100 border-4 border-amber-300 rounded-lg p-8 relative h-64">
          <div class="text-center mb-4">
            <h2 class="text-2xl font-bold text-amber-900">Certificate of Excellence</h2>
            <p class="text-amber-700">This certifies that</p>
            <h3 class="text-xl text-amber-800 my-2">John Doe</h3>
            <p class="text-amber-700">has successfully completed</p>
            <p class="text-lg font-semibold text-amber-800">Advanced Web Development</p>
          </div>

          <!-- Official seal -->
          <.dm_art_signature
            id="seal-official"
            content="★"
            size="large"
            color="#d97706"
            rotation="0"
            right="50%"
            top="50%"
          />
        </div>
        """
      }
    ]
  end
end