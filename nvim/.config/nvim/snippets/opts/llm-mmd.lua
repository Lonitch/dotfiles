return {
  ["state diagram"] = [[
Syntax:
1. Basic State: `stateName` or `state "Description" as stateName`
2. Transitions: `State1 --> State2` or `State1 --> State2 : Label`
3. Start/End: `[*] --> FirstState`, `LastState --> [*]`
4. Composite: `state StateName { SubState1 SubState2 }`
5. Choice: Use `<<choice>>`
6. Fork/Join: Use `<<fork>>` and `<<join>>`
7. Notes: `note right of StateName: Note text`
8. Concurrency: Use `--` within composite states
9. Direction: `direction TB` or `LR`
10. Comments: Use `%%`
11. Styling: `classDef className property:value;`
12. Spaces in names: `state "State with spaces" as stateId`
Caveats:
- Define states before using in transitions
- Use consistent naming
- Close all composite states
- Don't link internal states of different composites
- Avoid reserved keywords as state names
- Don't style start/end states or within composites
  ]],

  ["flowchart"] = [[
Syntax:
- Start with "flowchart" or "graph" followed by direction (TD, TB, BT, RL, LR)
- Define nodes:
  Simple node: nodeId
  Node with text: nodeId[Text]
  Node shapes: ()round, []rectangle, {}diamond, [(cylinder)], ((circle))
- Connect nodes:
  Arrow: -->
  Open link: ---
  Text on links: -->|text| or ---|text|---
  Dotted link: -.->, -.-, -.->
  Thick link: ==>, ===, ===>
- Styling:
  Link styles: linkStyle 3 stroke:#ff3,stroke-width:4px;
  Node styles: style nodeId fill:#f9f,stroke:#333,stroke-width:4px;
  Classes: classDef className fill:#f9f,stroke:#333,stroke-width:4px;
  class nodeId1,nodeId2 className;
Caveats:
- Avoid using "end" as a node name in lowercase. Capitalize it or use a workaround.
- When connecting nodes starting with "o" or "x", add a space or capitalize (e.g., "A--- ops" or "A---Ops").
- Use quotes for text with special characters: nodeId["Text with (special) characters"]
- For subgraphs, if any node is linked to the outside, the subgraph direction will be ignored.
- Markdown strings (wrapped in ``) allow formatting but may affect diagram layout.
- Interaction features (click events) are disabled when using securityLevel='strict'.
- CSS styling requires including the appropriate CSS in your HTML.
- FontAwesome icons require including FontAwesome CSS in your HTML.
- The "elk" renderer is experimental and requires Mermaid version 9.4+.
- Semicolons at the end of statements are optional.
- A single space is allowed between vertices and links, but not between a vertex and its text or a link and its text.
  ]],

  ["quadrant chart"] = [[
Syntax:
- Start the chart with "quadrantChart"
- Title: Use "title" followed by the chart title text
- Axes:
  x-axis: "x-axis <left text> --> <right text>"
  y-axis: "y-axis <bottom text> --> <top text>"
  You can omit the right/top text and arrow
- Quadrant labels:
  quadrant-1: top right
  quadrant-2: top left
  quadrant-3: bottom left
  quadrant-4: bottom right
- Points:
  Format: "<point name>: [x, y]"
  x and y values must be between 0 and 1
- Styling points:
  Direct: "<point>: [x, y] radius: <value>, color: <color>, stroke-color: <color>, stroke-width: <value>"
  Classes: Define with "classDef <className> <styles>" and apply with "<point>:::className: [x, y]"
Caveats:
- If no points are present, axis text and quadrant labels will be centered in their respective quadrants.
- With points present, x-axis labels appear at the bottom, y-axis labels at the bottom of their quadrants, and quadrant text at the top of each quadrant.
- Point coordinates (x, y) must be between 0 and 1.
- For axes, you can specify both parts (e.g., left and right for x-axis) or just the first part (left for x-axis, bottom for y-axis).
- When styling points, direct styling takes precedence over class styling, which takes precedence over theme styling.
- The chart can be further customized using various configuration parameters for sizes, padding, and colors.
- Theme variables are available for customizing colors of different chart elements.
  ]],

  ["pie chart"] = [[
Syntax:
- Start the diagram with the keyword "pie".
- Optionally, use "showData" to display actual data values after the legend text.
- Optionally, add a title using "title" followed by the title text in quotes.
- Define data sets with the following format:
  "Label" : value
  Each data set should be on a new line.
  Labels must be in quotes.
  Values should be positive numbers (up to two decimal places are supported).
  Pie slices will be ordered clockwise in the same order as the labels are defined.
Example:
  pie
    "Dogs" : 386
    "Cats" : 85
    "Rats" : 15
Caveats:
- The "showData" keyword is optional. If used, it must come immediately after "pie" and before the title (if any).
- The title is optional. If used, it must come after "showData" (if present) and before the data sets.
- Labels must be enclosed in quotes, even if they're single words.
- Values must be positive numbers. Negative numbers or non-numeric values are not supported.
- The sum of all values does not need to equal 100. The chart will automatically calculate percentages based on the total of all values.
- There's no built-in limit to the number of slices, but too many slices may make the chart hard to read.
- You can configure the text position of labels using the "textPosition" parameter, which ranges from 0.0 (center) to 1.0 (outside edge). The default is 0.75.
- Colors are assigned automatically and cannot be specified in the basic syntax.
  ]],
  ["mindmap"] = [[
Syntax:
1. Start the diagram with "mindmap"
2. Use indentation to define the hierarchy of nodes:
   - Root node at the leftmost position
   - Child nodes indented further right than their parents
3. Node shapes:
   - Default: No special syntax
   - Square: [square]
   - Rounded square: (rounded square)
   - Circle: ((circle))
   - Bang: )bang(
   - Cloud: (cloud)
   - Hexagon: {{hexagon}}
4. Icons: Use ::icon() syntax, e.g., ::icon(fa fa-book)
5. Classes: Use ::: followed by class names, e.g., :::urgent large
6. Markdown strings: Enclose in backticks (`), supports **bold** and *italics*
Caveats:
1. Mindmap is an experimental diagram type, and syntax may change in future releases.
2. The icon integration is particularly experimental.
3. Icons and custom classes need to be set up by the site administrator or integrator.
4. Indentation is relative to previous rows. Unclear indentation is resolved by finding the nearest clear parent.
8. Markdown strings automatically wrap text, unlike traditional strings which require <br> tags.
  ]],

  ["xy chart"] = [[
Syntax:
1. Start the chart with "xychart-beta"
2. Orientation (optional):
   - Default is vertical
   - For horizontal: "xychart-beta horizontal"
3. Title:
   - title "Your Chart Title"
   - Single words don't need quotes, multi-word titles do
4. X-axis:
   - Numeric: x-axis title min --> max
   - Categorical: x-axis "title" [cat1, "cat2 with space", cat3]
5. Y-axis (always numeric):
   - y-axis title min --> max
   - y-axis title (range auto-generated from data)
6. Line chart:
   - line [value1, value2, value3, ...]
7. Bar chart:
   - bar [value1, value2, value3, ...]
8. Simplest example:
   xychart-beta
     line [1.3, 0.6, 2.4, -0.34]
Caveats:
1. XY chart is in beta, so syntax may change in future versions.
2. X-axis can be categorical or numeric, but Y-axis is always numeric.
3. Both x-axis and y-axis configurations are optional. If not provided, the range will be auto-generated from the data.
4. All text values containing spaces must be enclosed in quotes.
5. Themes for XY charts reside inside the xychart attribute. To set theme variables, use:
   %%{init: { "themeVariables": {"xyChart": {"titleColor": "#ff0000"} } }}%%
6. The chart can be customized with various configuration parameters like width, height, font sizes, padding, etc.
7. You can customize colors using the plotColorPalette theme variable.
8. The chart reserves a minimum of 50% space for plots by default (configurable).
9. Axis configurations include options for labels, titles, ticks, and axis lines, which can all be shown/hidden and customized.
  ]],

  ["sankey diagram"] = [[
Syntax:
1. Start the diagram with "sankey-beta"
2. Use CSV-like format with 3 columns: source, target, and value
3. Each row represents a flow from source to target with the given value
4. Columns should be separated by commas
5. Empty lines are allowed for visual separation
6. If a field contains a comma, enclose it in double quotes
7. To use double quotes in a field, use two double quotes inside the quoted string
Example:
    sankey-beta
    source,target,value
    A,X,5
    A,Y,7
    B,X,3
    B,Y,4
Caveats:
1. This is an experimental diagram type, so syntax may change in future versions
2. Only 3 columns are allowed in the CSV-like input
3. The CSV format used is close to but not exactly standard CSV
4. Configuration options are set separately, not in the diagram syntax itself
5. Link colors can be customized using the 'linkColor' config option:
   - 'source', 'target', 'gradient', or a hex color code
6. Node alignment can be adjusted with the 'nodeAlignment' config option:
   - 'justify', 'center', 'left', or 'right'
7. Diagram dimensions can be set in the configuration
8. The rendering may differ slightly from other Sankey diagram implementations
  ]],

  ["architecture chart"] = [[
Syntax:
1. Start the diagram with "architecture-beta"
2. Groups:
   - Syntax: group {group id}({icon name})[{title}] (in {parent id})?
   - Example: group public_api(cloud)[Public API]
   - Nested groups: group private_api(cloud)[Private API] in public_api
3. Services:
   - Syntax: service {service id}({icon name})[{title}] (in {parent id})?
   - Example: service database(db)[Database]
   - In a group: service database(db)[Database] in private_api
4. Edges:
   - Syntax: {serviceId}{{group}}?:{T|B|L|R} {<}?--{>}? {T|B|L|R}:{serviceId}{{group}}?
   - Direction: Specify with L (left), R (right), T (top), B (bottom)
   - Arrows: Use < or > for arrow direction
   - Group edges: Use {group} modifier after serviceId
5. Junctions:
   - Syntax: junction {junction id} (in {parent id})?
6. Icons:
   - Default icons: cloud, database, disk, internet, server
   - Custom icons: Use format "name:icon-name" after registering icon packs
Caveats:
1. This is a beta feature (v11.1.0+), so syntax may change in future versions.
2. Components can be declared in any order, but identifiers must be previously declared.
3. Group IDs cannot be used for specifying edges directly.
4. The {group} modifier for edges can only be used for services within a group.
5. Custom icons require additional setup:
   - Icon packs need to be registered before use.
   - Users can use icons from iconify.design or add their own.
6. When using custom icons, the icon pack name must be specified along with the icon name.
7. Junctions are a special type of node for potential 4-way splits between edges.
8. The diagram layout is automatically determined, so precise positioning of elements is not directly controlled by the user.
  ]]
}
