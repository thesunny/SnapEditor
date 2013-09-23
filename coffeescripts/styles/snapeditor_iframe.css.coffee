# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define [], ->
  """
    * {
      outline: none;
    }

    body {
      font-family: Arial, Helvetica, sans-serif;
      font-size: 14px;
      color: #333333;
      line-height: 175%;
      padding: 0 5px;
    }

    h1, h2, h3, h4, h5, h6 {
      color: black;
    }

    h1 {
      font-size: 200%;
      margin: 1.5em 0 0.75em;
    }

    h2 {
      font-size: 180%;
      margin: 1.25em 0 0.75em;
    }

    h3 {
      font-size: 160%;
      margin: 1em 0 0.75em;
    }

    h4 {
      font-size: 140%;
      margin: 1em 0 0.75em;
    }

    h5 {
      font-size: 120%;
      margin: 1em 0 0.75em;
    }

    h6 {
      font-size: 110%;
      margin: 1em 0 0.75em;
    }

    p {
      margin: 0.5em 0 0.75em;
    }

    p:first-child {
      margin-top: 0;
    }

    ul, ol { margin: 1.12em 0; margin-left: 40px; }
    ol ul, ul ol, ul ul, ol ol { margin-top: 0; margin-bottom: 0; }
    ul { list-style: disc outside none; }
    ul ul { list-style-type: circle; }
    ul ul ul { list-style-type: square; }
    ul ul ul ul { list-style-type: disc; }
    ol { list-style: decimal outside none; }
    ol ol { list-style-type: lower-latin; }
    ol ol ol { list-style-type: lower-roman; }
    ol ol ol ol { list-style-type: decimal; }
    li { display: list-item; }

    table { font-size: 100%; border-spacing: 2px; border-collapse: collapse; width: 100%; margin-bottom: 1em; }
    thead, tbody, tfoot { vertical-align: middle; }
    td, th, tr { vertical-align: inherit; }
    table, th, td { border: 1px solid #5c5c5c; }

    a:hover {
      cursor: default;
    }

    b {
      font-weight: bolder;
    }

    i {
      font-style: italic;
    }

    sup {
      vertical-align: super;
    }

    sub {
      vertical-align: sub;
    }

    code {
      font-family: monospace;
    }
  """
