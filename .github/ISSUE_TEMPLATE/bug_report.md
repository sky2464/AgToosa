name: Bug report
description: Create a report to help us improve
labels: ["bug"]
body:
  - type: markdown
    attributes:
      value: |
        Thanks for taking the time to fill out this bug report!
  - type: textarea
    id: what-happened
    attributes:
      label: What happened?
      description: Also tell us what you expected to happen.
      placeholder: Tell us what you did and what happened.
    validations:
      required: true
  - type: input
    id: version
    attributes:
      label: AgToosa Version
      description: Run `bash install.sh --version`
      placeholder: e.g. 1.0.0
    validations:
      required: true
  - type: dropdown
    id: assistant
    attributes:
      label: AI Assistant used
      options:
        - Cursor
        - Windsurf
        - Claude Code
        - Gemini CLI
        - GitHub Copilot
        - Other
    validations:
      required: true
  - type: textarea
    id: logs
    attributes:
      label: Relevant Log Output
      description: Please copy and paste any relevant log output or error messages.
      render: shell
  - type: checkboxes
    id: checks
    attributes:
      label: Checks
      options:
        - label: I have searched for existing issues.
          required: true
        - label: I am using the latest version of AgToosa.
          required: true
