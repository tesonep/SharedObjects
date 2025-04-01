Class {
	#name : 'BaselineOfSharedObjects',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfSharedObjects',
	#package : 'BaselineOfSharedObjects'
}

{ #category : 'baselines' }
BaselineOfSharedObjects >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ 

			spec baseline: 'NeoJSON' with: [ spec repository: 'github://svenvc/NeoJSON/repository' ].
			spec baseline: 'PharoWin32' with: [ 
					spec
						loads: 'core-tests'; 
						repository: 'github://tesonep/pharo-com' ].

			spec
				package: 'SharedObjects';
				package: 'SharedObjects-IO';
				package: 'SharedObjects-Extensions' with: [ spec requires: 'NeoJSON' ];
				package: 'SharedObjects-Tests' with: [ 
					spec requires: #('SharedObjects' 'SharedObjects-IO' 'SharedObjects-Extensions') ]
	 ]
]
