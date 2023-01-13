import { LightningElement, api } from 'lwc';
import getRecordCount from '@salesforce/apex/PageViewCountController.viewCount';
import getGenericPageViewCount from '@salesforce/apex/PageViewCountController.GenericPageViewCount';

export default class PageViewCount extends LightningElement {
    @api recordId;
    views='';
    communityViews='';
    editCount='';
    error;

    connectedCallback(){
    
    var url = document.URL;
    console.log('URL: ', url);

    getRecordCount({recordId: this.recordId, URl : url})
        .then((result) => {
            console.log('********RecordCount*********** '+ JSON.stringify(result));
            this.views = result;
        })
        .catch((error)=>{
        this.error = error.body.message;
        })

    if(this.recordId == null){
    getGenericPageViewCount({URL : url})
        .then((result) => {
            console.log('********RecordCount*********** '+ JSON.stringify(result));
            this.views = result;
        })
        .catch((error)=>{
        this.error = error.body.message;
        })
    }

        
    }

}