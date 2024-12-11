declare const hljs: typeof import('highlight.js')['default'];

const KEYWORDS = [
  'open', 'as', 'module',
  'sig', 'abstract', 'extends', 'in', 'enum',
  'set', 'one', 'lone', 'some', 'disj', 'seq', 'no',
  'run', 'exactly', 'check', 'assert', 'pred', 'fun', 'fact', 'for', 'steps',
  'let', 'implies', 'else', 'not', 'iff', 'all', 'this', 'var',
  'always', 'eventually', 'once', 'after', 'before', 'releases', 'until', 'triggered', 'since',
];

const LITERALS = [
  'none', 'univ', 'iden', 'Int',
];

hljs.registerLanguage('alloy', (hljs) => {
  return {
    case_insensitive: false,
    keywords: KEYWORDS.join(' '),
    literal: LITERALS.join(' '),
    contains: [
      {
        scope: 'string',
        begin: '"', end: '"'
      },
      hljs.COMMENT('/\\*', '\\*/'),
      hljs.C_LINE_COMMENT_MODE,
      hljs.QUOTE_STRING_MODE,
      hljs.COMMENT('--', '\n'),
    ]
  };
});
