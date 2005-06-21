package WebGUI::Help::Asset_Collaboration;

our $HELP = {
	'collaboration add/edit' => {
		title => 'collaboration add/edit title',
		body => 'collaboration add/edit body',
		fields => [
                        {
                                title => 'display last reply',
                                description => 'display last reply description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'system template',
                                description => 'system template description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'thread template',
                                description => 'thread template description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'post template',
                                description => 'post template description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'search template',
                                description => 'search template description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'notification template',
                                description => 'notification template description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'who moderates',
                                description => 'who moderates description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'who posts',
                                description => 'who posts description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'threads/page',
                                description => 'threads/page description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'posts/page',
                                description => 'posts/page description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'karma/post',
                                description => 'karma/post description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'karma spent to rate',
                                description => 'karma spent to rate description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'karma rating multiplier',
                                description => 'karma rating multiplier description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'filter code',
                                description => 'filter code description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'sort by',
                                description => 'sort by description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'sort order',
                                description => 'sort order description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'archive after',
                                description => 'archive after description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'attachments/post',
                                description => 'attachments/post description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'editTimeout',
                                description => 'editTimeout description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'allow replies',
                                description => 'allow replies description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'edit stamp',
                                description => 'edit stamp description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'rich edit',
                                description => 'rich edit description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'content filter',
                                description => 'content filter description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'use preview',
                                description => 'use preview description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'moderate',
                                description => 'moderate description',
                                namespace => 'Asset_Collaboration',
                        },
		],
		related => [
			{
				tag => 'content filtering',
				namespace => 'WebGUI'
			},
		]
	},

	'collaboration template labels' => {
		title => 'collaboration template labels title',
		body => 'collaboration template labels body',
		fields => [
		],
		related => [
		]
	},

	'collaboration post list template variables' => {
		title => 'collaboration post list template variables title',
		body => 'collaboration post list template variables body',
		fields => [
		],
		related => [
			{
				tag => 'asset fields',
				namespace => 'Asset'
			},
		]
	},

	'collaboration template' => {
		title => 'collaboration template title',
		body => 'collaboration template body',
		fields => [
		],
		related => [
			{
		   		tag => 'collaboration template labels',
				namespace => 'Asset_Collaboration',
			},
			{
		   		tag => 'collaboration post list template variables',
				namespace => 'Asset_Collaboration',
			},
		]
	},

	'collaboration search template' => {
		title => 'collaboration search template title',
		body => 'collaboration search template body',
		fields => [
		],
		related => [
			{
		   		tag => 'collaboration post list template variables',
				namespace => 'Asset_Collaboration',
			},
		]
	},

};

1;
