({
    onInit : function(component, event, helper) {
        
        var pageRef = component.get("v.pageReference");
        console.log("hrllo");
        if (pageRef) {
            var state = pageRef.state;
            var base64Context = state.inContextOfRef;
            console.log(base64Context);
            if (base64Context && base64Context.startsWith("1\.")) {
                base64Context = base64Context.substring(2);
                console.log(base64Context);
                var addressableContext = JSON.parse(window.atob(base64Context));  
                console.log("addressableContext.attributes.recordId",addressableContext.attributes.recordId);
                if (addressableContext.attributes && addressableContext.attributes.recordId) {
                    component.set("v.recordId", addressableContext.attributes.recordId);
                }
            }
        }
        
        
    },
    
    reInit : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
    }
})

/*({
	myAction : function(component, event, helper) {
		
	}
})*/